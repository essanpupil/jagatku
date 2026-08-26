resource "vault_pki_secret_backend_intermediate_cert_request" "csr-request" {
  backend     = data.terraform_remote_state.vault_common.outputs.pki_int_path
  type        = "internal"
  common_name = "Intermediate Certificate Authority jagatku.local"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  backend     = data.terraform_remote_state.vault_common.outputs.pki_path
  common_name = "new_intermediate"
  csr         = vault_pki_secret_backend_intermediate_cert_request.csr-request.csr
  format      = "pem_bundle"
  ttl         = 15480000
  issuer_ref  = data.terraform_remote_state.root_ca.outputs.issuer_id
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = data.terraform_remote_state.vault_common.outputs.pki_int_path
  certificate = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
}

resource "vault_pki_secret_backend_issuer" "intermediate" {
  backend     = data.terraform_remote_state.vault_common.outputs.pki_int_path
  issuer_ref  = vault_pki_secret_backend_intermediate_set_signed.intermediate.imported_issuers[0]
  issuer_name = "int-ca-issuer"
}
