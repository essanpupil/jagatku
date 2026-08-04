resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "observability"
  }
}

resource "helm_release" "k8s_monitoring" {
  name       = "k8s-monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "k8s-monitoring"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "4.1.6"
  atomic     = true
  wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}

#trivy:ignore:KSV0108
resource "kubernetes_service_v1" "prometheus_external" {
  metadata {
    name      = "prometheus-external"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  spec {
    type = "ExternalName"
    #trivy:ignore:KSV0108
    external_name = "prometheus.laptop1.local"
  }
}

#trivy:ignore:KSV0108
resource "kubernetes_service_v1" "loki_external" {
  metadata {
    name      = "loki-external"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  spec {
    type = "ExternalName"
    #trivy:ignore:KSV0108
    external_name = "loki.laptop1.local"
  }
}
