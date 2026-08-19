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
    path         = "sys/mounts/auth/*"
    capabilities = ["read", "update"]
    description  = "Allow cicd to view available backend auth"
  }

  rule {
    path         = "auth/kubernetes/config"
    capabilities = ["read", "update"]
    description  = "Allow cicd to update kubernetes auth config"
  }
}

resource "vault_policy" "this" {
  name   = "laptop1"
  policy = data.vault_policy_document.this.hcl
}

import {
  to = vault_policy.this
  id = "laptop1"
}
