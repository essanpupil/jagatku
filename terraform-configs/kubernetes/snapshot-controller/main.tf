resource "helm_release" "this" {
  name            = "longhorn"
  repository      = "https://piraeus.io/helm-charts/"
  chart           = "snapshot-controller"
  namespace       = "kube-system"
  version         = "5.1.1"
  cleanup_on_fail = true
  atomic          = true

  # Prevents Terraform timeouts if a chart has complex post-install jobs
  wait = false
  values = [
    file("${path.module}/values.yaml")
  ]
}
