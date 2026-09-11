include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "${dirname(find_in_parent_folders("project.hcl"))}/vpc"

  mock_outputs = {
    network_id = "vpc-mock12345"
    private_subnetworks = [
      {
        id = "subnetwork-mock12345"
      }
    ]
  }
  mock_outputs_allowed_terraform_commands = ["plan", "init"]
}


locals {
  project_config = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  project_name = local.project_config.locals.project_name
}

terraform {
  source = "git::https://github.com/essanpupil/iac-modules.git//gcp/gke?ref=v0.0.4-1"
  // source = "/Users/essan/Code/iac-modules/gcp/gke"
}

inputs = {
  project_id = local.project_config.locals.project_id
  name = "jagat-kube-dev"
  service_account_id = "jagat-kube-dev"
  network_id = dependency.vpc.outputs.network_id
  subnetwork_id = dependency.vpc.outputs.private_subnetworks[0]
  location = "us-east1"
}
