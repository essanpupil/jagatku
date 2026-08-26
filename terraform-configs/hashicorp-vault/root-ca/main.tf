resource "vault_pki_secret_backend_root_cert" "root_2023" {
  backend     = data.terraform_remote_state.vault_common.outputs.pki_path
  type        = "internal"
  common_name = "jagatku.local"
  ttl         = 315360000
  issuer_name = "root-2023"
}

resource "vault_pki_secret_backend_issuer" "root_2023" {
  backend                        = data.terraform_remote_state.vault_common.outputs.pki_path
  issuer_ref                     = vault_pki_secret_backend_root_cert.root_2023.issuer_id
  issuer_name                    = vault_pki_secret_backend_root_cert.root_2023.issuer_name
  revocation_signature_algorithm = "SHA256WithRSA"
}

resource "vault_pki_secret_backend_role" "role" {
  backend          = data.terraform_remote_state.vault_common.outputs.pki_path
  name             = "2023-servers-role"
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allow_subdomains = true
  allow_any_name   = true
}

resource "vault_pki_secret_backend_config_urls" "config-urls" {
  backend                 = data.terraform_remote_state.vault_common.outputs.pki_path
  issuing_certificates    = ["http://vault.laptop1.local/v1/pki/ca"]
  crl_distribution_points = ["http://vault.laptop1.local/v1/pki/crl"]
}
