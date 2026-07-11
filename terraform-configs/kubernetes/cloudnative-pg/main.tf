resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "database"
  }
}

resource "helm_release" "this" {
  name       = "cloudnative-pg"
  repository = "helm repo add cnpg https://cloudnative-pg.github.io/charts"
  chart      = "cloudnative-pg"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "0.29.0"
  # atomic     = true
  # wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}