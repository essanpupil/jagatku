resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_service_account_v1" "this" {
  metadata {
    name      = local.service_account_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
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
      service_account_name : kubernetes_service_account_v1.this.metadata[0].name
    })
  ]
}

resource "kubernetes_role_v1" "this" {
  metadata {
    name = "${local.service_account_name}-role"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  rule {
    api_groups     = [""]
    resources      = ["serviceaccounts/token"]
    verbs          = ["create"]
  }
}

resource "kubernetes_role_binding_v1" "this" {
  metadata {
    name = "${local.service_account_name}-role-binding"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.this.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.this.metadata[0].name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding_v1" "this" {
  metadata {
    name = "cert-manager-token-creator-binding"
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

resource "kubernetes_manifest" "cluster_issuer" {
  manifest = yamldecode(<<EOF
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: cert-man-cluster-issuer
    spec:
      vault:
        server: http://vault.laptop1.local
        path: ${data.terraform_remote_state.vault_common.outputs.pki_path}/sign/${local.pki_role_name}
        auth:
          kubernetes:
            mountPath: /v1/auth/${data.terraform_remote_state.vault_common.outputs.kubernetes_path}
            role: ${vault_kubernetes_auth_backend_role.this.role_name}
            # For ClusterIssuer, create this service account and RBAC in
            # cert-manager's cluster resource namespace.
            serviceAccountRef:
              name: ${kubernetes_service_account_v1.this.metadata[0].name}
              audiences:
                - "https://kubernetes.default.svc.cluster.local"
  EOF
  )
}
