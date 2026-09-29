include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "project" {
  config_path = "${dirname(find_in_parent_folders("project.hcl"))}"

  mock_outputs = {
    project_id   = "prj-id-mock"
    project_name = "prj-name-mock"
  }
  mock_outputs_allowed_terraform_commands = ["init"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

locals {
  cluster_config = read_terragrunt_config(find_in_parent_folders("cluster.hcl"))
}

terraform {
  # TODO: commit gcp/compute-address in iac-modules and pin an immutable tag
  source = "git::https://github.com/essanpupil/iac-modules.git//gcp/compute-address?ref=v0.0.8"
  # source = "/Users/essan/Code/iac-modules/gcp/compute-address"
}

inputs = {
  name        = "${dependency.project.outputs.project_name}-argo-cd-ingress"
  project_id  = dependency.project.outputs.project_id
  description = "Static public IP for the argo-cd GKE Ingress load balancer."

  # A GKE Ingress (ingressClassName gce / gke-iap) provisions a global
  # Application Load Balancer, so the address must be global, not regional.
  scope        = "GLOBAL"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
  ip_version   = "IPV4"

  # region is only used by REGIONAL addresses and is kept here so the two
  # scopes stay configured from the same cluster location.
  region = local.cluster_config.locals.location
}
