data "kubernetes_config_map_v1" "kube_root_ca" {
  metadata {
    name      = "kube-root-ca.crt"
    namespace = "kube-system"
  }
}
