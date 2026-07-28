resource "helm_release" "this" {
  name       = "csi-driver-nfs"
  repository = "https://kubernetes-csi.github.io/csi-driver-nfs"
  chart      = "csi-driver-nfs"
  namespace  = "kube-system"
  version    = "4.9.0"
  # atomic     = true
  # wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}
