locals {
  vault_connection_name = "vault-conn"
  vault_auth_name = "vault-auth"
}

data "terraform_remote_state" "kubernetes_vault" {
  backend = "consul"
  config = {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/hashicorp-vault/common"
  }
}
resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "vault"
  }
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
    file("${path.module}/values.yaml")
  ]
}

resource "kubernetes_manifest" "vault_laptop1_connection" {
  depends_on = [ helm_release.vso ]
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


resource "kubernetes_manifest" "backstage_vault_auth" {
  manifest = yamldecode(<<EOF
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultAuth
    metadata:
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
      name: ${local.vault_auth_name}
    spec:
      vaultConnectionRef: ${local.vault_connection_name}
      method: kubernetes
      mount: ${data.terraform_remote_state.kubernetes_vault.outputs.kubernetes_path}
      kubernetes:
        role: ${vault_kubernetes_auth_backend_role.this.role_name}
        serviceAccount: default
        audiences:
          - vault
  EOF
  )
}

output "vault_connection_name" {
  value = local.vault_connection_name
}
