resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "metallb-system"
  }
}

resource "helm_release" "this" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "0.16.1"
  atomic     = true
  wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}
