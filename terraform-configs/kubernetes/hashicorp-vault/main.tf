locals {
  vault_connection_name = "vault-connection"
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "vault"
  }
}

resource "helm_release" "this" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "0.34.0"
  atomic     = true
  wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "helm_release" "vso" {
  name       = "vault-secrets-operator"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault-secrets-operator"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "1.5.1"
  atomic     = true
  wait       = true
  values = [
    file("${path.module}/values-cso.yaml")
  ]
}

resource "kubernetes_manifest" "vault_laptop1_connection" {
  depends_on = [helm_release.vso]

  manifest = yamldecode(<<EOF
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultConnection
    metadata:
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
      name: ${local.vault_connection_name}
    spec:
      address: http://vault.laptop1.local
  EOF
  )
}

output "vault_connection_name" {
  value = local.vault_connection_name
}
