include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "${dirname(find_in_parent_folders("project.hcl"))}/vpc"

  mock_outputs = {
    network_id   = "vpc-mock12345"
    network_name = "mock_network"
    private_subnetworks_id = ["subnetwork-mock12345"]
    private_subnetworks_name = ["subnetwork-mock12345"]
  }
  mock_outputs_allowed_terraform_commands = ["plan", "init"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}


locals {
  project_config = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  cluster_config = read_terragrunt_config("cluster.hcl")
  project_name   = local.project_config.locals.project_name
}

terraform {
  source = "git::https://github.com/essanpupil/iac-modules.git//gcp/gke?ref=v0.0.7"
  # source = "/Users/essan/Code/iac-modules/gcp/gke"
}

inputs = {
  project_id         = local.project_config.locals.project_id
  name               = local.cluster_config.locals.cluster_name
  service_account_id = local.cluster_config.locals.service_account_id
  network_id         = dependency.vpc.outputs.network_id
  network_name       = dependency.vpc.outputs.network_name
  subnetwork_id    = dependency.vpc.outputs.private_subnetworks_id[0]
  location           = local.cluster_config.locals.location
  create_bastion = false
  enable_private_endpoint = false
  public_authorized_cidr = "180.252.255.20/32"
  enabled_secret_manager_config = true
}
