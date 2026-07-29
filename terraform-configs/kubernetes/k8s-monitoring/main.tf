data "terraform_remote_state" "observability_namespace" {
  backend = "consul"

  config = {
    address = "192.168.1.2:8500"
    scheme  = "http"
    path    = "terraform-configs/kubernetes/prometheus-agent"
  }
}

resource "helm_release" "k8s_monitoring" {
  name       = "k8s-monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "k8s-monitoring"
  namespace  = data.terraform_remote_state.observability_namespace.outputs.namespace
  version    = "4.1.6"
  atomic     = true
  wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}
