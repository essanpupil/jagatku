locals {
  vault_policy_name          = "backstage-jagat"
  secret_name                = "backstage-db-secret"
  db_username                = "backstager"
  service_account_name       = "backstager-sa"
  service_account_token_name = "backstager-sa-token" # checkov:ignore:CKV_SECRET_6
  vault_auth_name            = "vault-auth"
  cert_issuer_name           = "backstage-cert-issuer"
}
