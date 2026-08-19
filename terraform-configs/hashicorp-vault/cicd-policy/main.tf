resource "vault_policy" "this" {
  name   = "laptop1"
  policy = <<EOT
path "grafana-token/metadata/*" {
    capabilities = ["read", "list"]
}
path "grafana-token/data/*" {
    capabilities = ["create", "read", "update", "list"]
}
EOT
}

import {
  to = vault_policy.this
  id = "laptop1"
}
