data "terraform_remote_state" "vso" {
  backend = "consul"
  config = {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/kubernetes/hashicorp-vault"
  }
}

data "terraform_remote_state" "kubernetes_vault" {
  backend = "consul"
  config = {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/hashicorp-vault/common"
  }
}

data "terraform_remote_state" "intermediate_ca" {
  backend = "consul"
  config = {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/hashicorp-vault/intermediate-ca"
  }
}

data "vault_policy_document" "this" {
  rule {
    path         = "secret/data/backstage/*"
    capabilities = ["read", "list"]
    description  = "Access secrets for backstage"
  }
}
