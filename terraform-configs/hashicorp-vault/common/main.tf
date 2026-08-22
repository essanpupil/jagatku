resource "vault_mount" "kvv2" {
  path = "sensitive-data"
  type = "kv-v2"
  options = {
    version = "2"
  }
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes"
}
