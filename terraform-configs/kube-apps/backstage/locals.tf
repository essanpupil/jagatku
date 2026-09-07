locals {
  secret_name          = "backstage-secrets"
  db_username          = "backstager"
  service_account_name = "backstage-sa"
  db_cluster_name      = "backstage-db-cluster-1"
  tls_secret_name      = "backstage-jagatku-local-tls"

  secrets = [
    {
      vault_static_name = "backstage-secrets-vault-static"
      name              = "backstage-secrets"
      type              = "kubernetes.io/basic-auth"
      data = {
        password = "PleaseChangeMe" #checkov:skip=CKV_SECRET_6
        username = "backstager"
      }
    },
    {
      vault_static_name = "backstage-gh-pat-vault-static"
      name              = "backstage-gh-pat"
      type              = "generic"
      data = {
        github_token = "changeme"
      }
    }
  ]
}
