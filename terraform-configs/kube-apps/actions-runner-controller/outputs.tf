output "controller_service_account_name" {
  value = local.arc_service_account_name
}

output "controller_namespace_name" {
  value = module.helm.namespace_name
}
