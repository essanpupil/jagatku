resource "helm_release" "this" {
  name       = "kube-state-metrics"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  namespace  = "kube-system"
  version    = "8.3.1"
  atomic     = true
  wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}
