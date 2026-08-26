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

resource "kubernetes_role_v1" "example" {
  metadata {
    name      = local.kubernetes_vault_role
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels = {
      test = "cert-manager-vault-kube-auth"
    }
  }

  rule {
    api_groups     = [""]
    resources      = ["serviceaccounts/token"]
    resource_names = [local.service_account_name]
    verbs          = ["create"]
  }
}

resource "kubernetes_role_binding_v1" "example" {
  metadata {
    name      = "${local.kubernetes_vault_role}-binding"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = local.kubernetes_vault_role
  }
  subject {
    kind      = "ServiceAccount"
    name      = local.service_account_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
}

resource "kubernetes_cluster_role_v1" "this" {
  metadata {
    name = "cert-manager-token-creator"
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts/token"]
    verbs      = ["create"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "this" {
  metadata {
    name = "cert-manager-token-creator-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cert-manager-token-creator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cert-manager"
    namespace = "cert-manager"
  }
}
