resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "gitops"
  }
}

resource "helm_release" "this" {
  name       = "argo-cd"
  repository = "oci://ghcr.io/argoproj/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "10.1.3"
  # atomic     = true
  # wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}
