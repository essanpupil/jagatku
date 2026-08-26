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
    path         = data.terraform_remote_state.vault_common.outputs.kubernetes_path
    capabilities = ["read"]
    description  = "Grafana auth from cicd"
  }
  rule {
    path         = "sys/mounts/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Enable secrets engine"
  }

  rule {
    path         = "sys/mounts"
    capabilities = ["read", "list"]
    description  = "List enabled secrets engine"
  }

  rule {
    path         = "${data.terraform_remote_state.vault_common.outputs.pki_path}*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo", "patch"]
    description  = "Work with pki secrets engine"
  }
}
