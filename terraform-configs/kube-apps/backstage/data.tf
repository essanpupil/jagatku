data "terraform_remote_state" "intermediate_ca" {
  backend = "consul"
  config = {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/hashicorp-vault/intermediate-ca"
  }
}

data "terraform_remote_state" "vault_common" {
  backend = "consul"
  config = {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/hashicorp-vault/common"
  }
}

# data "terraform_remote_state" "cert_manager" {
#   backend = "consul"
#   config = {
#     address = "consul.laptop1.local"
#     scheme  = "http"
#     path    = "terraform-configs/kubernetes/cert-manager"
#   }
# }

data "vault_policy_document" "this" {
  rule {
    path         = vault_kv_secret_v2.backstage_config.path
    capabilities = ["create", "read", "update"]
    description  = "Access secrets for backstage"
  }
}
