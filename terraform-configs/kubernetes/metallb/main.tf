resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "metallb-system"
  }
}

resource "helm_release" "this" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "0.16.1"
  atomic     = true
  wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "kubernetes_manifest" "main_pool" {
  manifest = yamldecode(<<-EOF
    apiVersion: metallb.io/v1beta1
    kind: IPAddressPool
    metadata:
      name: main-pool
      namespace: ${ kubernetes_namespace_v1.this.metadata[0].name }
    spec:
      addresses:
        - 192.168.1.200-192.168.1.250
  EOF
  )
}

resource "kubernetes_manifest" "l2_advertisement" {
  manifest = yamldecode(<<-EOF
    apiVersion: metallb.io/v1beta1
    kind: L2Advertisement
    metadata:
      name: l2-advertisement
      namespace: ${ kubernetes_namespace_v1.this.metadata[0].name }
    spec:
      ipAddressPools:
        - main-pool
  EOF
  )
}
