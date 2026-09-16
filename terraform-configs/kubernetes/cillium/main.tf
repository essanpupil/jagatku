resource "helm_release" "this" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  namespace  = "kube-system"
  version    = "1.19.6"
  atomic     = false
  wait       = false  # cilium takes very long time to finished
  # timeout = 900
  values = [
    file("${path.module}/values.yaml")
  ]
}
