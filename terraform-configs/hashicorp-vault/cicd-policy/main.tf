data "vault_policy_document" "this" {
  rule {
    path         = "grafana-token/metadata/*"
    capabilities = ["read", "list"]
    # description  = "allow all on secrets"
  }

  rule {
    path         = "grafana-token/data/*"
    capabilities = ["create", "read", "update", "list"]
    # description  = "allow all on secrets"
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
