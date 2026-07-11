resource "helm_release" "this" {
  name       = "nfs-ganesha"
  repository = "https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/"
  chart      = "nfs-server-provisioner"
  namespace  = "kube-system"
  # version         = "32.4.3"
  # cleanup_on_fail = true
  # atomic          = true

  # Prevents Terraform timeouts if a chart has complex post-install jobs
  wait = false
  values = [
    file("${path.module}/values.yaml")
  ]
}
