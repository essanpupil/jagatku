resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "vault"
  }
}

resource "helm_release" "this" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "0.34.0"
  atomic     = true
  wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}
