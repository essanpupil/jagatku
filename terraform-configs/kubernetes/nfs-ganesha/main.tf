# resource "helm_release" "this" {
#   name       = "nfs-ganesha"
#   repository = "https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/"
#   chart      = "nfs-server-provisioner"
#   namespace  = "kube-system"
#   cleanup_on_fail = true
#   atomic          = true

#   wait = false
#   values = [
#     file("${path.module}/values.yaml")
#   ]
# }
