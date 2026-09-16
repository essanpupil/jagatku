module "helm" {
  #checkov:skip=CKV_TF_1
  #checkov:skip=CKV_TF_2
  source = "git::https://github.com/essanpupil/iac-modules.git//kubernetes/helm?ref=v0.0.7-1"
  # source           = "/Users/essan/Code/iac-modules/kubernetes/helm"
  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart            = "gha-runner-scale-set-controller"
  chart_version    = "0.14.2"
  release_name     = "arc"
  create_namespace = true
  namespace_name   = "arc-system"
  values           = <<EOF
  serviceAccount:
    create: true
    name: ${local.arc_service_account_name}
  EOF
}
