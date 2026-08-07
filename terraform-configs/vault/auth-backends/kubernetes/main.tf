resource "vault_auth_backend" "this" {
  type = "kubernetes"
  path = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "example" {
  backend         = vault_auth_backend.this.path
  kubernetes_host = "http://kubernetes.jagat.local"
}
