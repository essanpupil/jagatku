#trivy:ignore:KSV-0037
resource "kubernetes_manifest" "coredns_apiserver" {
  manifest = yamldecode(file("${path.module}/coredns-apiserver.yaml"))
}
