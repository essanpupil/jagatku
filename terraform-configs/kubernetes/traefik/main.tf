resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "traefik"
  }
}

resource "helm_release" "this" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "41.0.2"
  atomic     = true
  wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}
