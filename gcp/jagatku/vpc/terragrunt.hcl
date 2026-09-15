include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "project" {
  config_path = "${dirname(find_in_parent_folders("project.hcl"))}"

  mock_outputs = {
    project_id   = "prj-id-mock"
    project_name = "prj-name-mock"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "init"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

locals {
  network_name   = "vpc-dev"
  subnets = [
    {
      name          = "priv-jagatku"
      ip_cidr_range = "10.2.0.0/16"
      region        = "us-east1"
    }
  ]
}

terraform {
  source = "git::https://github.com/essanpupil/iac-modules.git//gcp/vpc?ref=v0.0.7"
  # source = "/Users/essan/Code/iac-modules/gcp/vpc"
}

inputs = {
  network_name    = "${dependency.project.outputs.project_name}-${local.network_name}"
  project_id      = dependency.project.outputs.project_id
  private_subnets = local.subnets
}
