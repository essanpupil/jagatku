resource "kubernetes_manifest" "coredns_apiserver" {
  manifest = yamldecode(file("${path.module}/coredns-apiserver.yaml"))
}

resource "kubernetes_manifest" "alloy" {
  manifest = yamldecode(templatefile("${path.module}/alloy-network-policy.yaml", {
    namespace = data.terraform_remote_state.k8s_monitoring.outputs.namesapce
  }))
}
