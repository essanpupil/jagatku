output "pki_path" {
  value = vault_mount.pki.path
}

output "issuer_id" {
  value = vault_pki_secret_backend_issuer.root_2023.issuer_id
}

output "vault_pki_secret_backend_root_cert_root_2023" {
  value = vault_pki_secret_backend_root_cert.root_2023.certificate
}
