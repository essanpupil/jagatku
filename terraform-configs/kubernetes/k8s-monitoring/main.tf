resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "observability"
  }
}

resource "helm_release" "k8s_monitoring" {
  name       = "k8s-monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "k8s-monitoring"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "4.1.6"
  atomic     = true
  wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "kubernetes_config_map_v1_data" "example" {
  metadata {
    name      = "coredns"
    namespace = "kube-system"
  }
  data = {
    "Corefile" = <<-EOF
      .:53 {
        errors
        health {
          lameduck 5s
        }
        ready
        # Custom private dns entries
        hosts {
          # Format: IP_ADDRESS HOSTNAME
          192.168.1.50 prometheus.laptop1.local
          192.168.1.50 loki.laptop1.local
          # fallthrough passes unmatched queries to next plugin
          fallthrough
        }
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          fallthrough in-addr.arpa ip6.arpa
          ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
          max_concurrent 1000
        }
        cache 30 {
          disable success cluster.local
          disable denial cluster.local
        }
        loop
        reload
        loadbalance
    }
  EOF
  }
}
