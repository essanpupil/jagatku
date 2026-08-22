# resource "helm_release" "this" {
#   name       = "secrets-store-csi-driver"
#   repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
#   chart      = "secrets-store-csi-driver"
#   namespace  = "kube-system"
#   atomic     = true
#   wait       = true
#   values = [
#     file("${path.module}/values.yaml")
#   ]
# }
