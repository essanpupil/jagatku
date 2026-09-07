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
    templatefile("${path.module}/values.yaml", {
      service_account_name = local.service_account_name
      tls_secret           = local.tls_secret_name
    })
  ]
}

module "secrets" {
  # checkov:skip=CKV_TF_1: I owned the remote repo, safe to use tag as ref
  source                    = "git::https://github.com/essanpupil/iac-modules.git//vault-kube-secrets?ref=v0.0.2-2"
  vault_role_name           = "backstage-app-role"
  kubernetes_path           = data.terraform_remote_state.vault_common.outputs.kubernetes_path
  kubernetes_namespace      = kubernetes_namespace_v1.this.metadata[0].name
  create_service_account    = true
  vault_kv_secrets          = local.secrets
  kv_secret_path            = data.terraform_remote_state.vault_common.outputs.kv_secret_path
  service_account_name      = local.service_account_name
  vautl_policy_name         = "backstage-jagat"
  cluster_role_binding_name = "backstage-role-binding"
  vault_auth_name           = "backstage-vault-auth"
}

moved {
  from = vault_policy.this
  to   = module.secrets.vault_policy.this
}

moved {
  from = vault_kv_secret_v2.backstage_config
  to   = module.secrets.vault_kv_secret_v2.this[0]
}

moved {
  from = vault_kubernetes_auth_backend_role.this
  to   = module.secrets.vault_kubernetes_auth_backend_role.this
}

moved {
  from = kubernetes_service_account_v1.this
  to   = module.secrets.kubernetes_service_account_v1.kube_sa[0]
}

moved {
  from = kubernetes_manifest.backstage_secret
  to   = module.secrets.kubernetes_manifest.vault_static_secret[0]
}

moved {
  from = kubernetes_manifest.backstage_vault_auth
  to   = module.secrets.kubernetes_manifest.vault_auth
}

moved {
  from = kubernetes_cluster_role_binding_v1.keycloak
  to   = module.secrets.kubernetes_cluster_role_binding_v1.kube_rb
}

# resource "kubernetes_service_account_v1" "this" {
#   metadata {
#     name      = local.service_account_name
#     namespace = kubernetes_namespace_v1.this.metadata[0].name
#   }
# }

# resource "kubernetes_cluster_role_binding_v1" "keycloak" {
#   metadata {
#     name = "backstage-role-binding"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "system:auth-delegator"
#   }
#   subject {
#     kind      = "ServiceAccount"
#     name      = kubernetes_service_account_v1.this.metadata[0].name
#     namespace = kubernetes_namespace_v1.this.metadata[0].name
#   }
# }
