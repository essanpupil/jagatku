resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

import {
  to = vault_auth_backend.kubernetes
  id = "kubernetes"
}

output "kubernetes_path" {
  value = vault_auth_backend.kubernetes.path
}
