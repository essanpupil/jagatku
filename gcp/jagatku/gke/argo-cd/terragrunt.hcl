include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "cluster" {
  path = find_in_parent_folders("cluster.hcl")
}

dependency "argo_cd_ip" {
  config_path = "${dirname(find_in_parent_folders("cluster.hcl"))}/argo-cd-ip"

  mock_outputs = {
    address = "203.0.113.10"
    name    = "jagatku-argo-cd-ingress"
    id      = "projects/prj-id-mock/global/addresses/jagatku-argo-cd-ingress"
  }
  mock_outputs_allowed_terraform_commands = ["init"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

dependencies {
  paths = [
    dirname(find_in_parent_folders("cluster.hcl")),
    "${dirname(find_in_parent_folders("cluster.hcl"))}/argo-cd-ip"
  ]
}

terraform {
  source = "git::https://github.com/essanpupil/iac-modules.git//kubernetes/helm?ref=v0.0.8"
  # source = "/Users/essan/Code/iac-modules/kubernetes/helm"
}

inputs = {
  chart_version    = "10.9.1"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  release_name     = "argo-cd"
  create_namespace = true
  namespace_name   = "argo-cd-system"

  # The heredoc below is interpolating, so the dependency references are
  # substituted by terragrunt. Escape any literal dollar as $$ instead.
  #
  # hostname is the nip.io name of the address reserved by the argo-cd-ip unit.
  # The global-static-ip-name annotation is required: without it the Ingress
  # provisions its own ephemeral address and the hostname above stops matching.
  values = <<EOF
global:
  domain: "argocd.${dependency.argo_cd_ip.outputs.address}.nip.io"
server:
  ingress:
    enabled: true
    controller: "gke"
    ingressClassName: "gce"
    annotations:
      kubernetes.io/ingress.global-static-ip-name: "${dependency.argo_cd_ip.outputs.name}"
    gke:
      managedCertificate:
        create: true
      frontendConfig:
        redirectToHttps:
          enabled: true
          responseCodeName: RESPONSE_CODE
  service:
    classname: "gce"
    # type: LoadBalancer is intentionally not set. An L4 regional external LB
    # would expose argocd-server directly and bypass the Ingress and its TLS,
    # and GKE assigns the Ingress address above, so the Service stays ClusterIP.
EOF
}
