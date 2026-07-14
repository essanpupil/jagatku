# resource "grafana_folder" "this" {
#   title = "Kubernetes Critical Events"
#   uid   = "kubernetes"
# }

# resource "grafana_dashboard" "this" {
#   folder      = grafana_folder.this.uid
#   config_json = file("${path.module}/kubernetes-dashboard.json")
# }
