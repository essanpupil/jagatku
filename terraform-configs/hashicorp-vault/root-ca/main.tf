resource "vault_mount" "pki" {
  path        = "pki"
  type        = "pki"
  description = "PKI mount for https certs"

  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 315360000
}

output "pki_path" {
  value = vault_mount.pki.path
}

output "issuer_id" {
  value = vault_pki_secret_backend_issuer.root_2023.issuer_id
}

resource "vault_pki_secret_backend_root_cert" "root_2023" {
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = "Root CA"
  ttl         = 315360000
  issuer_name = "root-2023"
}

resource "vault_pki_secret_backend_issuer" "root_2023" {
  backend                        = vault_mount.pki.path
  issuer_ref                     = vault_pki_secret_backend_root_cert.root_2023.issuer_id
  issuer_name                    = vault_pki_secret_backend_root_cert.root_2023.issuer_name
  revocation_signature_algorithm = "SHA256WithRSA"
}

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki.path
  name             = "2023-servers"
  ttl              = 86400
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["jagatku.local", "laptop1.local"]
  allow_subdomains = true
  allow_any_name   = true
}

resource "vault_pki_secret_backend_config_urls" "config-urls" {
  backend                 = vault_mount.pki.path
  issuing_certificates    = ["http://vault.laptop1.local/v1/pki/ca"]
  crl_distribution_points = ["http://vault.laptop1.local/v1/pki/crl"]
}
