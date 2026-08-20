resource "vault_policy" "this" {
  name   = "laptop1"
  policy = data.vault_policy_document.this.hcl
}

import {
  to = vault_policy.this
  id = "laptop1"
}
