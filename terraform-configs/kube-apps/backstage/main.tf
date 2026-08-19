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

resource "vault_policy" "this" {
  name   = "backstage-jagat"
  policy = data.vault_policy_document.this.hcl
}

resource "vault_kubernetes_auth_backend_role" "this" {
  backend                          = data.terraform_remote_state.kubernetes_vault.outputs.kubernetes_path
  role_name                        = "backstage-app-role"
  bound_service_account_names      = ["defaults"]
  bound_service_account_namespaces = [kubernetes_namespace_v1.this.metadata[0].name]
  token_policies                   = [vault_policy.this.name]
  token_ttl                        = 1800 # 30 minutes
}

resource "kubernetes_manifest" "db_secrets" {
  #checkov:skip=CKV_SECRET_6
  #checkov:skip=APPSEC_SECRET_6
  manifest = yamldecode(<<EOF
    apiVersion: secrets-store.csi.x-k8s.io/v1
    kind: SecretProviderClass
    metadata:
      name: backstage-db-auth
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
    spec:
      provider: vault
      parameters:
        vaultAddress: "http://vault.laptop1.local"
        roleName: ${vault_kubernetes_auth_backend_role.this.role_name}
        objects: |
          - objectName: "db_password"
            secretPath: "/secret/data/backstage/config"
            secretKey: "password"
          - objectName: "db_username"
            secretPath: "/secret/data/backstage/config"
            secretKey: "username"
  EOF
  )
}
