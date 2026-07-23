resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "kafka"
  }
}

resource "helm_release" "this" {
  name       = "strimzi-kafka-operator"
  repository = "oci://quay.io/strimzi-helm/strimzi-kafka-operator"
  chart      = "strimzi-kafka-operator"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "1.1.0"
  # atomic     = true
  # wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}
