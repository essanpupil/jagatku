resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "queue"
  }
}

resource "helm_release" "this" {
  name            = "kafka"
  repository      = "https://charts.bitnami.com/bitnami"
  chart           = "kafka"
  namespace       = kubernetes_namespace_v1.this.metadata[0].name
  version         = "32.4.3"
  cleanup_on_fail = true
  atomic          = true

  # Prevents Terraform timeouts if a chart has complex post-install jobs
  wait = false
  values = [
    file("${path.module}/values.yaml")
  ]
}
