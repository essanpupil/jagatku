resource "kubernetes_manifest" "coredns_apiserver" {
  manifest = yamldecode(file("${path.module}/coredns-apiserver.yaml"))
}

resource "kubernetes_manifest" "scheduler_apiserver" {
  manifest = yamldecode(file("${path.module}/scheduler-apiserver.yaml"))
}

resource "kubernetes_manifest" "controller_manager_apiserver" {
  manifest = yamldecode(file("${path.module}/controller-manager-apiserver.yaml"))
}
