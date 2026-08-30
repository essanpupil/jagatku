data "terraform_remote_state" "vault_common" {
  backend = "consul"
  config = {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/hashicorp-vault/common"
  }
}

data "vault_policy_document" "this" {
  # rule {
  #   path         = "sys/mounts"
  #   capabilities = ["read", "list"]
  #   description  = "List enabled secrets engine"
  # }
  rule {
    path         = "sensitive-data/data/*"
    capabilities = ["read", "list"]
    description = "sensitive-data/data/test-static-secret"
  }
  rule {
    path         = "sensitive-data/metadata/*"
    capabilities = ["read", "list"]
    description = "sensitive-data/metadata/test-static-secret"
  }
}

# output "namespace" {
#   value = kubernetes_namespace_v1.this.metadata.0.name
# }

# output "service_account_name" {
#   value = kubernetes_service_account_v1.this.metadata.0.name
# }
