resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "storage"
  }
}

resource "helm_release" "this" {
  name            = "longhorn"
  repository      = "https://charts.longhorn.io"
  chart           = "longhorn"
  namespace       = kubernetes_namespace_v1.this.metadata[0].name
  version         = "1.12.0"
  cleanup_on_fail = true
  atomic          = true

  # Prevents Terraform timeouts if a chart has complex post-install jobs
  wait = false
  values = [
    file("${path.module}/values.yaml")
  ]
}
