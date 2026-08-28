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

resource "vault_kv_secret_v2" "keycloak_db" {
  mount = data.terraform_remote_state.vault_common.outputs.kv_secret_path
  name  = local.secret_name

  data_json = jsonencode({
    db_username = local.db_username
    db_password = "PleaseChangeMe" # checkov:skip=CKV_SECRET_6 will be changed in vault web ui
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

resource "kubernetes_manifest" "backstage_secret" {
  manifest = yamldecode(<<EOF
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultStaticSecret
    metadata:
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
      name: ${local.secret_name}-static
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
      name: keycloak-db-cluster
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
    spec:
      instances: 3
      storage:
        size: 1Gi
  EOF
  )
}
