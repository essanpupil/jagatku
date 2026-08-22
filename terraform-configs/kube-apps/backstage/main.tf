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
    })
  ]
}

resource "kubernetes_cluster_role_binding_v1" "backstage" {
  metadata {
    name = "backstage-vault"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = local.service_account_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
}

resource "kubernetes_secret_v1" "backstager_sa" {
  metadata {
    name      = "${local.service_account_name}-token"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = local.service_account_name
    }
  }
  type = "kubernetes.io/service-account-token"
}
