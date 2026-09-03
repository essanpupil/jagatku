resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "arc-system"
  }
}

resource "helm_release" "this" {
  name       = "arc"
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set-controller"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  # version    = "2.10.0"
  #   atomic     = true
  #   wait       = true
  values = [
    templatefile("${path.module}/values.yaml", {
      service_account_name = kubernetes_service_account_v1.this.metadata[0].name
      gh_pat_secret_name   = local.gh_token_secret_name
    })
  ]
}

resource "kubernetes_service_account_v1" "this" {
  metadata {
    name      = local.service_account_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding_v1" "keycloak" {
  metadata {
    name = "backstage-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.this.metadata[0].name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
}
