resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = local.vault_namespace
  }
}

# resource "kubernetes_service_account_v1" "this" {
#   metadata {
#     name      = local.vault_kube_sa_name
#     namespace = kubernetes_namespace_v1.this.metadata[0].name
#   }
# }

# resource "vault_policy" "this" {
#   name   = local.vault_kube_policy_name
#   policy = data.vault_policy_document.this.hcl
# }


# resource "vault_kubernetes_auth_backend_role" "this" {
#   backend                          = "kubernetes"
#   role_name                        = local.kube_vault_role
#   bound_service_account_names      = ["vault-secrets-operator-controller-manager"]
#   bound_service_account_namespaces = [kubernetes_namespace_v1.this.metadata[0].name]
#   token_policies                   = [vault_policy.this.name]
#   token_ttl                        = 1800 # 30 minutes
# }

resource "helm_release" "vso" {
  name       = "vault-secrets-operator"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault-secrets-operator"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "1.5.1"
  atomic     = true
  wait       = true
  values = [
    templatefile("${path.module}/values.yaml", {})
    #   allowed_namespaces               = ["platform", "keycloak"]
    #   mount                            = data.terraform_remote_state.vault_common.outputs.kubernetes_path
    #   # vault_kubernetes_role            = vault_kubernetes_auth_backend_role.this.role_name
    #   kubernetes_vault_service_account = "vault-secrets-operator-controller-manager"
    # })
  ]
}

# resource "kubernetes_cluster_role_binding_v1" "this" {
#   metadata {
#     name = "vso-auth-delegator-binding"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "system:auth-delegator"
#   }
#   subject {
#     kind      = "ServiceAccount"
#     name      = "vault-secrets-operator-controller-manager"
#     namespace = kubernetes_namespace_v1.this.metadata[0].name
#   }
# }

# resource "kubernetes_manifest" "test" {
#   manifest = yamldecode(<<EOF
#     apiVersion: secrets.hashicorp.com/v1beta1
#     kind: VaultStaticSecret
#     metadata:
#       name: test-static-secret
#       namespace: vault
#     spec:
#       mount: sensitive-data
#       type: kv-v2
#       path: test-static-secret
#       version: 2
#       refreshAfter: 30s
#       destination:
#         create: true
#         name: "test-static-secret"
#         overwrite: true
#         type: kubernetes.io/basic-auth
#   EOF
#   )
# }
