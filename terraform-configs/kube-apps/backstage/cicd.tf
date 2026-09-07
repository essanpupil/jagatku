resource "helm_release" "gh_action_runner" {
  name       = "gha-runner-scale-set"
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set"
  namespace  = kubernetes_namespace_v1.this.metadata[0].name
  version    = "0.14.2"
  #   atomic     = true
  #   wait       = true
  values = [
    templatefile("${path.module}/cicd-values.yaml", {
      github_config_url   = data.terraform_remote_state.backstage_repo.outputs.repo_url
      github_token_secret = local.secrets[1].name
    })
  ]
}
