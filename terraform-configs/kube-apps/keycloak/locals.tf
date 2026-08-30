locals {
  app_secret_name       = "app-keycloak-secrets"
  superuser_secret_name = "postgres-keycloak-secrets"
  db_username           = "keycloak-db-user"
  db_name               = "keycloak-db"
  vault_policy_name     = "keycloak-policy"
  service_account_name  = "keycloak-sa"
  vault_auth_name       = "keycloak-vault-auth"
  db_cluster_name       = "keycloak-db-cluster"
}
