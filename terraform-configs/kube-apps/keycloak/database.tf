resource "vault_policy" "this" {
  name   = local.vault_policy_name
  policy = data.vault_policy_document.this.hcl
}

resource "vault_kubernetes_auth_backend_role" "this" {
  backend                          = data.terraform_remote_state.vault_common.outputs.kubernetes_path
  role_name                        = "backstage-app-role"
  bound_service_account_names      = [kubernetes_service_account_v1.keycloak_sa.metadata[0].name]
  bound_service_account_namespaces = [kubernetes_namespace_v1.this.metadata[0].name]
  token_policies                   = [vault_policy.this.name]
  token_ttl                        = 1800 # 30 minutes
  audience                         = "vault"
}

resource "vault_kv_secret_v2" "superuser_passwd" {
  mount = data.terraform_remote_state.vault_common.outputs.kv_secret_path
  name  = "${local.secret_name}-superuser"

  data_json = jsonencode({
    password = "PleaseChangeMe" # checkov:skip=CKV_SECRET_6 will be changed in vault web ui
  })
}

resource "vault_kv_secret_v2" "app_passwd" {
  mount = data.terraform_remote_state.vault_common.outputs.kv_secret_path
  name  = local.secret_name

  data_json = jsonencode({
    username = local.db_username
    password = "PleaseChangeMe" # checkov:skip=CKV_SECRET_6 will be changed in vault web ui
  })
}

resource "kubernetes_manifest" "backstage_vault_auth" {
  manifest = yamldecode(<<EOF
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultAuth
    metadata:
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
      name: ${local.vault_auth_name}
    spec:
      method: kubernetes
      mount: ${data.terraform_remote_state.vault_common.outputs.kubernetes_path}
      kubernetes:
        role: ${vault_kubernetes_auth_backend_role.this.role_name}
        serviceAccount: ${kubernetes_service_account_v1.keycloak_sa.metadata[0].name}
        audiences:
          - vault
  EOF
  )
}

resource "kubernetes_manifest" "superuser_secret" {
  manifest = yamldecode(<<EOF
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultStaticSecret
    metadata:
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
      name: ${local.secret_name}-superuser
    spec:
      vaultAuthRef: ${kubernetes_namespace_v1.this.metadata[0].name}/${local.vault_auth_name}
      mount: ${data.terraform_remote_state.vault_common.outputs.kv_secret_path}
      type: kv-v2
      path: "${local.secret_name}-superuser"
      version: 2
      refreshAfter: 60s
      destination:
        create: true
        name: "${local.secret_name}-superuser"
        overwrite: true
    EOF
  )
}

resource "kubernetes_manifest" "keycloak_app_secret" {
  manifest = yamldecode(<<EOF
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultStaticSecret
    metadata:
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
      name: ${local.secret_name}-app
    spec:
      vaultAuthRef: ${kubernetes_namespace_v1.this.metadata[0].name}/${local.vault_auth_name}
      mount: ${data.terraform_remote_state.vault_common.outputs.kv_secret_path}
      type: kv-v2
      path: ${local.secret_name}
      version: 2
      refreshAfter: 60s
      destination:
        create: true
        name: ${local.secret_name}
        overwrite: true
    EOF
  )
}

resource "kubernetes_manifest" "cnfg" {
  manifest = yamldecode(<<EOF
    apiVersion: postgresql.cnpg.io/v1
    kind: Cluster
    metadata:
      name: ${local.db_cluster_name}
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
    spec:
      serviceAccountName: ${kubernetes_service_account_v1.keycloak_sa.metadata[0].name}
      instances: 3
      storage:
        size: 1Gi
      bootstrap:
        initdb:
          database: "keycloak-db"
          owner: ${local.db_username}
      superuserSecret:
        name: "${local.secret_name}-superuser"
  EOF
  )
}

resource "kubernetes_manifest" "keycloak_db_app_role" {
  manifest = yamldecode(<<EOF
    apiVersion: postgresql.cnpg.io/v1
    kind: DatabaseRole
    metadata:
      name: keycloak-app-role
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
    spec:
      cluster:
        name: ${local.db_cluster_name}
      name: ${local.db_username}
      login: true
      superuser: false
      createdb: true
      databaseRoleReclaimPolicy: delete
      inRoles:
        - pg_monitor
      passwordSecret:
        name: ${local.secret_name}
  EOF
  )
}
