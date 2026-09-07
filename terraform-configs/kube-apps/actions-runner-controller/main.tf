resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "arc-system"
  }
}

resource "helm_release" "arc" {
  name       = "arc"
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set-controller"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "0.14.2"
  atomic     = true
  #   wait       = true
  values = [
    templatefile("${path.module}/arc-values.yaml", {
      service_account_name = local.arc_service_account_name
    })
  ]
}
