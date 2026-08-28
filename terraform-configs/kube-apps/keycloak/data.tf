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
    path         = vault_kv_secret_v2.app_passwd.path
    capabilities = ["create", "read", "update"]
    description  = "Access secrets for backstage"
  }
  rule {
    path         = vault_kv_secret_v2.superuser_passwd.path
    capabilities = ["create", "read", "update"]
    description  = "Access secrets for backstage"
  }
  rule {
    path         = data.terraform_remote_state.vault_common.outputs.kubernetes_path
    capabilities = ["create", "read", "update", "list", "patch"]
    description  = "Access secrets for backstage"
  }
  rule {
    path         = "${data.terraform_remote_state.vault_common.outputs.kubernetes_path}/login"
    capabilities = ["create", "read", "update", "list", "patch"]
    description  = "Access secrets for backstage"
  }
}
