resource "vault_policy" "this" {
  name   = local.vault_policy_name
  policy = data.vault_policy_document.this.hcl
}

resource "vault_kubernetes_auth_backend_role" "this" {
  backend                          = data.terraform_remote_state.kubernetes_vault.outputs.kubernetes_path
  role_name                        = "backstage-app-role"
  bound_service_account_names      = [local.service_account_name]
  bound_service_account_namespaces = [kubernetes_namespace_v1.this.metadata[0].name]
  token_policies                   = [vault_policy.this.name]
  token_ttl                        = 1800 # 30 minutes
}

resource "kubernetes_manifest" "vault_laptop1_connection" {
  manifest = yamldecode(<<EOF
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultConnection
    metadata:
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
      name: ${local.vault_connection_name}
    spec:
      address: http://vault.laptop1.local
  EOF
  )
}

resource "kubernetes_manifest" "backstage_vault_auth" {
  manifest = yamldecode(<<EOF
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultAuth
    metadata:
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
      name: ${local.vault_auth_name}
    spec:
      vaultConnectionRef: ${local.vault_connection_name}
      method: kubernetes
      mount: kubernetes
      kubernetes:
        role: ${vault_kubernetes_auth_backend_role.this.role_name}
        serviceAccount: ${local.service_account_name}
  EOF
  )
}

resource "vault_kv_secret_v2" "backstage_config" {
  mount = data.terraform_remote_state.kubernetes_vault.outputs.kv_secret_path
  name  = "backstage-config"

  data_json = jsonencode({
    db_username = local.db_username
    db_password = "ChangeMe"
  })
}

resource "kubernetes_manifest" "backstage_secret" {
  manifest = yamldecode(<<EOF
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultStaticSecret
    metadata:
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
      name: ${local.secret_name}-static
    spec:
      vaultAuthRef: ${local.vault_auth_name}
      mount: kvv2
      type: kv-v2
      path: ${vault_kv_secret_v2.backstage_config.path}
      version: 2
      refreshAfter: 60s
      destination:
        create: true
        name: ${local.secret_name}
    EOF
  )
}
