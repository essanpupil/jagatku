resource "vault_policy" "this" {
  name   = "cert-manager-policy"
  policy = data.vault_policy_document.this.hcl
}

resource "vault_pki_secret_backend_role" "cert_manager" {
  backend          = data.terraform_remote_state.vault_common.outputs.pki_path
  name             = local.pki_role_name
  ttl              = 3600
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = local.allowed_domains
  allow_subdomains = true
}

resource "vault_kubernetes_auth_backend_role" "this" {
  backend                          = data.terraform_remote_state.vault_common.outputs.kubernetes_path
  role_name                        = "cert-manager"
  bound_service_account_names      = [local.service_account_name]
  bound_service_account_namespaces = [kubernetes_namespace_v1.this.metadata[0].name]
  token_policies                   = [vault_policy.this.name]
  token_ttl                        = 1800 # 30 minutes
  audience = "https://kubernetes.default.svc.cluster.local"
}
