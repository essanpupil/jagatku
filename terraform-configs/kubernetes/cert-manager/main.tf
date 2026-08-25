resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "cet-manager"
  }
}

resource "helm_release" "this" {
  name       = "cert-manager"
  repository = "oci://quay.io/jetstack/charts"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "1.21.1"
  atomic     = true
  wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}
