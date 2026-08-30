data "terraform_remote_state" "vault_common" {
  backend = "consul"
  config = {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/hashicorp-vault/common"
  }
}

data "vault_policy_document" "this" {
  rule {
    path         = "${data.terraform_remote_state.vault_common.outputs.pki_path}/sign/${local.pki_role_name}"
    capabilities = ["create", "update"]
  }
  rule {
    path         = "${data.terraform_remote_state.vault_common.outputs.pki_path}/issue/${local.pki_role_name}"
    capabilities = ["create", "update"]
  }
}
