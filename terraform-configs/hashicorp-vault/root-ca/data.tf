data "terraform_remote_state" "vault_common" {
  backend = "consul"
  config = {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/hashicorp-vault/common"
  }
}
