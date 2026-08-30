data "terraform_remote_state" "vault_common" {
  backend = "consul"
  config = {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/hashicorp-vault/common"
  }
}

data "terraform_remote_state" "vault_secret_operator" {
  backend = "consul"
  config = {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/kubernetes/vault-secret-operator"
  }
}

data "vault_policy_document" "this" {
  rule {
    path         = vault_kv_secret_v2.app_passwd.path
    capabilities = ["create", "read", "update"]
    description  = "Access secrets for backstage"
  }
  rule {
    path         = vault_kv_secret_v2.superuser_passwd.path
    capabilities = ["create", "read", "update"]
    description  = "Access secrets for backstage"
  }
}
