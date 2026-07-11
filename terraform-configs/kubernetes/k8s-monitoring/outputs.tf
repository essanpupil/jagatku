output "namespace" {
  value       = kubernetes_namespace_v1.observability.metadata[0].name
  description = "Created namespace"
}
