resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "queue"
  }
}

resource "kubernetes_manifest" "strimzi" {
  manifest = yamldecode(
    file("${path.module}/strimzi.yaml")
  )
}

resource "kubernetes_manifest" "kafka" {
  depends_on = [kubernetes_manifest.strimzi]
  manifest = yamldecode(
    file("${path.module}/kafka-single-node.yaml")
  )
}
