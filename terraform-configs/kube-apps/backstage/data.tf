data "terraform_remote_state" "kubernetes_vault" {
  backend = "consul"
  config = {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/hashicorp-vault/common"
  }
}

data "vault_policy_document" "this" {
  rule {
    path         = "secret/data/backstage/*"
    capabilities = ["read", "list"]
    description  = "Access secrets for backstage"
  }
}
