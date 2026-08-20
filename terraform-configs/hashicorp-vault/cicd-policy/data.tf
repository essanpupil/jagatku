data "vault_policy_document" "this" {
  rule {
    path         = "grafana-token/metadata/*"
    capabilities = ["read", "list"]
    description  = "Grafana auth from cicd"
  }

  rule {
    path         = "grafana-token/data/*"
    capabilities = ["create", "read", "update", "list"]
    description  = "Grafana auth from cicd"
  }

  rule {
    path         = "secret/data/*"
    capabilities = ["create", "read", "update", "list", "delete"]
    description  = "Allow cicd to modify secrets data"
  }

  rule {
    path         = "secret/metadata/*"
    capabilities = ["create", "read", "update", "list", "delete"]
    description  = "Allow cicd to modify secrets metadata"
  }

  rule {
    path         = "sys/mounts/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow cicd to manage secrets engine"
  }

  rule {
    path         = "sys/mounts"
    capabilities = ["read", "list"]
    description  = "Allow cicd to list enabled secrets engine"
  }

  rule {
    path         = "pki*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo", "patch"]
    description  = "Work with pki secrets engine"
  }

  rule {
    path         = "auth/kubernetes/config"
    capabilities = ["read", "update"]
    description  = "Allow cicd to update kubernetes auth config"
  }

  rule {
    path         = "sys/policies/acl/*"
    capabilities = ["read", "list", "update"]
    description  = "Allow CICD to update application policy"
  }

  rule {
    path         = "auth/kubernetes/role/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "Allow CICD to update vault kubernetes auth role"
  }
}
