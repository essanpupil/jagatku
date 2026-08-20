output "pki_path" {
  value = vault_mount.pki_int.path
}

# output "issuer_ref" {
#   value = vault_pki_secret_backend_issuer.intermediate.issuer_ref
# }
