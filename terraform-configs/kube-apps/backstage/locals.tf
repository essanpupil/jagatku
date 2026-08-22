locals {
  vault_policy_name     = "backstage-jagat"
  secret_name           = "backstage-db-secret"
  db_username           = "backstager"
  service_account_name  = "backstager-sa"
  vault_connection_name = "backstage-vault-conn"
  vault_auth_name       = "vault-auth"
  vault_address         = "http://vault.laptop1.local"
}
