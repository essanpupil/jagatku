resource "helm_release" "this" {
  name       = "cillium"
  repository = "https://helm.cilium.io/"
  chart      = "cillium"
  namespace  = "kube-system"
  version    = "1.19.6"
  # atomic     = true
  # wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}