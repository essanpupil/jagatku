# resource "helm_release" "this" {
#   name       = "vault"
#   repository = "https://helm.releases.hashicorp.com"
#   chart      = "vault"
#   namespace  = "kube-system"
#   version    = "0.34.0"
#   atomic     = true
#   wait       = true
#   values = [
#     file("${path.module}/values.yaml")
#   ]
# }
