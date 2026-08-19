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

data "kubernetes_config_map_v1" "kube_root_ca" {
  metadata {
    name      = "kube-root-ca.crt"
    namespace = "kube-system"
  }
}

resource "vault_kubernetes_auth_backend_config" "example" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = "http://kubernetes.jagat.local"
  kubernetes_ca_cert = data.kubernetes_config_map_v1.kube_root_ca.data["ca.crt"]
}
