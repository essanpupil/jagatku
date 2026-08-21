resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "example" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = "http://kubernetes.jagat.local:6443"
  kubernetes_ca_cert = data.kubernetes_config_map_v1.kube_root_ca.data["ca.crt"]
}

resource "vault_mount" "kvv2" {
  path = "secret"
  type = "kv-v2"
  options = {
    version = "2"
  }
}
