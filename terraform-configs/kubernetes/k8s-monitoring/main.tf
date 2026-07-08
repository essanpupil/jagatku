resource "kubernetes_namespace_v1" "observability" {
  metadata {
    name = "observability"
  }
}

resource "helm_release" "k8s_monitoring" {
  name       = "k8s-monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "k8s-monitoring"
  namespace  = kubernetes_namespace_v1.observability.metadata[0].name
  version    = "4.1.6"
  atomic     = true
  wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}