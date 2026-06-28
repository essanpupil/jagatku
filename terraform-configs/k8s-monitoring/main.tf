resource "kubernetes_namespace_v1" "observability" {
  metadata {
    name = "observability"
  }
}

resource "helm_release" "k8s_monitoring" {
  name       = "k8s-monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "k8s-monitoring"
  namespace  = kubernetes_namespace_v1.observability.metadata[0].name
  version    = "4.1.6"
  values = [
    <<-EOF
    collectors:
      alloy-metrics:
        enabled: true
        presets: [medium, clustered, statefulset]

      alloy-logs:
        enabled: true
        presets: [small, filesystem-log-reader, daemonset]

      alloy-singleton:
        presets: [small, deployment]

    clusterEvents:
      enabled: true
      collector: alloy-singleton
    nodeLogs:
      enabled: true
      collector: alloy-logs
    hostMetrics:
      enabled: true
      collector: alloy-metrics
    
    cluster:
      name: "kubernetes"
    destinations:
      localPrometheus:
        type: prometheus
        url: http://192.168.1.2:9090

      hostedLogs:
        type: loki
        url: https://192.168.1.2/loki/api/v1/push
        auth:
          # type: basic
          # username: "my-username"
          # password: "my-password"
          tenantId: "jagatku"
    EOF
  ]
}
