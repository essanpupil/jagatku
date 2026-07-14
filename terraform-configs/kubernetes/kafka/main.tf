# resource "kubernetes_namespace_v1" "this" {
#   metadata {
#     name = "queue"
#   }
# }

# data "kubectl_path_documents" "strimzi" {
#   pattern = "${path.module}/strimzi.yaml"
# }

# resource "kubectl_manifest" "strimzi" {
#   for_each  = toset(data.kubectl_path_documents.strimzi.documents)
#   yaml_body = each.value
# }

# data "kubectl_path_documents" "kafka" {
#   pattern = "${path.module}/kafka-single-node.yaml"
# }

# resource "kubectl_manifest" "kafka" {
#   for_each  = toset(data.kubectl_path_documents.kafka.documents)
#   yaml_body = each.value
# }
