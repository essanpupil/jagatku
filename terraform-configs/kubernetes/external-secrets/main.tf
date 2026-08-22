resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "external-secrets"
  }
}

resource "helm_release" "vso" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "2.9.0"
  atomic     = true
  wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}
