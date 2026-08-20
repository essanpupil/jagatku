output "kubernetes_path" {
  value = vault_auth_backend.kubernetes.path
}

output "kv_secret_path" {
  value = vault_mount.kvv2.path
}
