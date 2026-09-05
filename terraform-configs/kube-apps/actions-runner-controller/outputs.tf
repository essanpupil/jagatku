output "controller_service_account_name" {
  value = local.arc_service_account_name
}

output "controller_namespace_name" {
  value = kubernetes_namespace_v1.this.metadata[0].name
}
