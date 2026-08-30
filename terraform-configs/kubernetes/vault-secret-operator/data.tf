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
    path         = "sensitive-data/data/test-static-secret"
    capabilities = ["read"]
    description = "sensitive-data/data/test-static-secret"
  }
}

output "namespace" {
  value = kubernetes_namespace_v1.this.metadata.0.name
}

output "service_account_name" {
  value = kubernetes_service_account_v1.this.metadata.0.name
}
