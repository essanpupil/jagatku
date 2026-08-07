data "terraform_remote_state" "k8s_monitoring" {
  backend = "consul"
  config = {
    address = "consul.laptop1.local"
    path    = "terraform-configs/kubernetes/k8s-monitoring"
  }
}
