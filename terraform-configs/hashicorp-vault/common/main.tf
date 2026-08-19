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

resource "vault_kubernetes_auth_backend_config" "example" {
  backend         = vault_auth_backend.kubernetes.path
  kubernetes_host = "http://kubernetes.jagat.local"
}
