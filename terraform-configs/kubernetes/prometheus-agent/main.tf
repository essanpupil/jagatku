resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "observability"
  }
}

resource "helm_release" "this" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "87.15.1"
  # atomic     = true
  # wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}
