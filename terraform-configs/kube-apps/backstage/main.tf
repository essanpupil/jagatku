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

# resource "vault_kubernetes_auth_backend_role" "k8s_role" {
#   backend                          = vault_auth_backend.kubernetes.path
#   role_name                        = "k8s-app-role"
#   bound_service_account_names      = ["webapp-sa"]
#   bound_service_account_namespaces = ["production"]
#   token_policies                   = ["webapp-policy"]
#   token_ttl                        = 1800 # 30 minutes
# }

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
        roleName: "backstage-db-role"
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
