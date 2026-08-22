resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = local.vault_namespace
  }
}

resource "kubernetes_service_account_v1" "this" {
  metadata {
    name      = local.vault_kube_sa_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
}

resource "vault_policy" "this" {
  name   = local.vault_kube_policy_name
  policy = data.vault_policy_document.this.hcl
}


resource "vault_kubernetes_auth_backend_role" "this" {
  backend                          = data.terraform_remote_state.kubernetes_vault.outputs.kubernetes_path
  role_name                        = local.kube_vault_role
  bound_service_account_names      = [kubernetes_service_account_v1.this.metadata[0].name]
  bound_service_account_namespaces = [kubernetes_namespace_v1.this.metadata[0].name]
  token_policies                   = [vault_policy.this.name]
  token_ttl                        = 1800 # 30 minutes
  audience                         = local.token_audience
}

resource "helm_release" "vso" {
  name       = "vault-secrets-operator"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault-secrets-operator"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "1.5.1"
  atomic     = true
  wait       = true
  values = [
    templatefile("${path.module}/values.yaml", {
      vault_namespace                  = kubernetes_namespace_v1.this.metadata[0].name
      allowed_namespaces               = ["platform"]
      mount                            = data.terraform_remote_state.kubernetes_vault.outputs.kubernetes_path
      vault_kubernetes_role            = vault_kubernetes_auth_backend_role.this.role_name
      kubernetes_vault_service_account = kubernetes_service_account_v1.this.metadata[0].name
      token_audiences                  = [local.token_audience]
    })
  ]
}
