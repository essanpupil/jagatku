resource "vault_pki_secret_backend_role" "intermediate_role" {
  backend          = data.terraform_remote_state.intermediate_ca.outputs.pki_path
  issuer_ref       = data.terraform_remote_state.intermediate_ca.outputs.issuer_ref
  name             = "backstage-jagatku-local"
  ttl              = 86400
  max_ttl          = 2592000
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["jagatku.local"]
  allow_subdomains = true
}

resource "vault_pki_secret_backend_cert" "backstage_jagatku_local" {
  depends_on  = [vault_pki_secret_backend_role.intermediate_role]
  issuer_ref  = data.terraform_remote_state.intermediate_ca.outputs.issuer_ref
  backend     = vault_pki_secret_backend_role.intermediate_role.backend
  name        = vault_pki_secret_backend_role.intermediate_role.name
  common_name = "backstage.jagatku.local"
  ttl         = 3600
  revoke      = true
}
