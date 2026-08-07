resource "kubernetes_manifest" "coredns_apiserver" {
  manifest = yamldecode(file("${path.module}/coredns-apiserver.yaml"))
}

resource "kubernetes_manifest" "alloy_coredns" {
  manifest = yamldecode(file("${path.module}/alloy-coredns.yaml"))
}
