locals {
  service_account_name        = "cert-manager"
  service_account_secret_name = "cert-manager-token"
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "this" {
  name       = "cert-manager"
  repository = "oci://quay.io/jetstack/charts"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "1.21.1"
  atomic     = true
  wait       = true
  values = [
    templatefile("${path.module}/values.yaml", {
      service_account_name : local.service_account_name
    })
  ]
}

resource "kubernetes_manifest" "sa_secret" {
  manifest = yamldecode(<<EOF
    apiVersion: v1
    kind: Secret
    metadata:
      name: ${local.service_account_secret_name}
      annotations:
        kubernetes.io/service-account.name: ${local.service_account_name}
    type: kubernetes.io/service-account-token
  EOF
  )
}
