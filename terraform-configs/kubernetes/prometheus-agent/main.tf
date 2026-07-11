data "terraform_remote_state" "observability_namespace" {
  backend = "consul"

  config = {
    address = "192.168.1.2:8500"
    scheme  = "http"
    path    = "terraform-configs/kubernetes/k8s-monitoring"
  }
}

resource "helm_release" "this" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = data.terraform_remote_state.observability_namespace.namespace
  version    = "87.15.1"
  # atomic     = true
  # wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}