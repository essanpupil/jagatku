resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "arc-system"
  }
}

resource "kubernetes_service_account_v1" "runner_set_sa" {
  metadata {
    name      = local.runner_set_service_account_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
}

module "secrets" {
  source                 = "git::https://github.com/essanpupil/iac-modules.git//vault-kube-secrets?ref=33a64c72548260d5e092996a1ef46ade80eebf6e"
  create_service_account = false
  service_account_name   = kubernetes_service_account_v1.runner_set_sa.metadata[0].name
  vault_role_name        = "github-action"
  kubernetes_path        = data.terraform_remote_state.vault_common.outputs.kubernetes_path
  kubernetes_namespace   = kubernetes_namespace_v1.this.metadata[0].name
  kv_secret_path         = data.terraform_remote_state.vault_common.outputs.kv_secret_path
  vault_kv_secrets = [{
    name = local.gh_token_secret_name
    type = "generic"
    data = {
      github_token = "ChangeMe"
    }
  }]
}

resource "helm_release" "arc" {
  name       = "arc"
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set-controller"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "0.14.2"
  atomic     = true
  #   wait       = true
  values = [
    templatefile("${path.module}/arc-values.yaml", {
      service_account_name = local.arc_service_account_name
    })
  ]
}

resource "helm_release" "runner_set" {
  depends_on = [helm_release.arc]
  name       = "arc-runner-set"
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  # version    = "2.10.0"
  atomic = true
  #   wait       = true
  values = [
    templatefile("${path.module}/runner-set-values.yaml", {
      gh_pat_secret_name = local.gh_token_secret_name
      namespace          = kubernetes_namespace_v1.this.metadata[0].name
      sa_name            = local.arc_service_account_name
    })
  ]
}
