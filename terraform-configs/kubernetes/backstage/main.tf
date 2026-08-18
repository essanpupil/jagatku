resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "platform"
  }
}

resource "helm_release" "this" {
  name       = "backstage"
  repository = "oci://ghcr.io/backstage/charts"
  chart      = "backstage"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "2.10.0"
  #   atomic     = true
  #   wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "kubernetes_manifest" "backstage_ingress_network_policy" {
  manifest = yamldecode(<<-EOF
    apiVersion: "cilium.io/v2"
    kind: CiliumClusterwideNetworkPolicy
    metadata:
      name: "allow-world-backstage"
    spec:
      endpointSelector:
        matchLabels:
          app.kubernetes.io/name: backstage
      ingress:
        - fromentities:
            - world
  EOF
  )
}
