resource "helm_release" "this" {
  name       = "csi-driver-nfs"
  repository = "https://kubernetes-csi.github.io/csi-driver-nfs"
  chart      = "csi-driver-nfs"
  namespace  = "kube-system"
  version    = "4.13.4"
  atomic     = true
  wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "kubernetes_manifest" "csi_driver" {
  manifest = yamldecode(<<EOF
    apiVersion: storage.k8s.io/v1beta1
    kind: CSIDriver
    metadata:
      name: nfs.csi.k8s.io
    spec:
      attachRequired: false
      volumeLifecycleModes:
        - Persistent
      fsGroupPolicy: File
  EOF
  )
}
