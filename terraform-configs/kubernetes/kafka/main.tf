resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "queue"
  }
}

# Read a standard multi-document YAML file
data "kubectl_path_documents" "strimzi" {
  pattern = "${path.module}/strimzi.yaml"
}

# Apply all manifests found in the files
resource "kubectl_manifest" "strimzi" {
  for_each  = toset(data.kubectl_path_documents.strimzi.documents)
  yaml_body = each.value
}

# Read a standard multi-document YAML file
data "kubectl_path_documents" "kafka" {
  pattern = "${path.module}/kafka-single-node.yaml"
}

# Apply all manifests found in the files
resource "kubectl_manifest" "kafka" {
  for_each  = toset(data.kubectl_path_documents.kafka.documents)
  yaml_body = each.value
}
