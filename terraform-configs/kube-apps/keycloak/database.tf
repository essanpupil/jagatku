resource "vault_policy" "this" {
  name   = local.vault_policy_name
  policy = data.vault_policy_document.this.hcl
}

resource "vault_kubernetes_auth_backend_role" "this" {
  backend                          = data.terraform_remote_state.vault_common.outputs.kubernetes_path
  role_name                        = "keycloak-app-role"
  bound_service_account_names      = [kubernetes_service_account_v1.keycloak_sa.metadata[0].name]
  bound_service_account_namespaces = [kubernetes_namespace_v1.this.metadata[0].name]
  token_policies                   = [vault_policy.this.name]
  token_ttl                        = 1800 # 30 minutes
}

resource "vault_kv_secret_v2" "superuser_passwd" {
  mount = data.terraform_remote_state.vault_common.outputs.kv_secret_path
  name  = local.superuser_secret_name

  data_json = jsonencode({
    username = "postgres"
    password = "PleaseChangeMe" # checkov:skip=CKV_SECRET_6 will be changed in vault web ui
  })
}

resource "vault_kv_secret_v2" "app_passwd" {
  mount = data.terraform_remote_state.vault_common.outputs.kv_secret_path
  name  = local.app_secret_name

  data_json = jsonencode({
    username = local.db_username
    password = "PleaseChangeMe" # checkov:skip=CKV_SECRET_6 will be changed in vault web ui
  })
}

resource "kubernetes_manifest" "vault_auth" {
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
  EOF
  )
}

resource "kubernetes_manifest" "superuser_secret" {
  manifest = yamldecode(<<EOF
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultStaticSecret
    metadata:
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
      name: ${local.superuser_secret_name}
    spec:
      vaultAuthRef: ${kubernetes_manifest.vault_auth.object.metadata.name}
      mount: ${data.terraform_remote_state.vault_common.outputs.kv_secret_path}
      type: kv-v2
      path: ${local.superuser_secret_name}
      version: 2
      refreshAfter: 10s
      destination:
        create: true
        name: ${local.superuser_secret_name}
        overwrite: true
        type: kubernetes.io/basic-auth
    EOF
  )
}

resource "kubernetes_manifest" "keycloak_app_secret" {
  manifest = yamldecode(<<EOF
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultStaticSecret
    metadata:
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
      name: ${local.app_secret_name}
    spec:
      vaultAuthRef: ${kubernetes_manifest.vault_auth.object.metadata.name}
      mount: ${data.terraform_remote_state.vault_common.outputs.kv_secret_path}
      type: kv-v2
      path: ${local.app_secret_name}
      version: 2
      refreshAfter: 10s
      destination:
        create: true
        name: ${local.app_secret_name}
        overwrite: true
        type: kubernetes.io/basic-auth
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
      postgresUID: 65534
      postgresGID: 65534
      serviceAccountName: ${kubernetes_service_account_v1.keycloak_sa.metadata[0].name}
      instances: 3
      storage:
        size: 1Gi
      podSecurityContext:
        fsGroup: 26
        fsGroupChangePolicy: "Always"
      bootstrap:
        initdb:
          database: ${local.db_name}
          owner: ${local.db_username}
          secret:
            name: ${local.app_secret_name}
      enableSuperuserAccess: true
      superuserSecret:
        name: ${local.superuser_secret_name}
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
        name: ${local.app_secret_name}
  EOF
  )
}
