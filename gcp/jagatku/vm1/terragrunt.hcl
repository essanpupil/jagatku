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

dependency "vpc" {
  config_path = "${dirname(find_in_parent_folders("project.hcl"))}/vpc"

  mock_outputs = {
    private_subnetworks_region = ["us-east1"]
  }
  mock_outputs_allowed_terraform_commands = ["init"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

terraform {
      source = "git::https://github.com/essanpupil/iac-modules.git//gcp/compute-instance?ref=v0.0.9-1"
    # source = "/Users/essan/Code/iac-modules//gcp/compute-instance"
}

inputs = {
    project_id = dependency.project.outputs.project_id
    name = "vm1"
    subnetwork_id = dependency.vpc.outputs.private_subnetworks_id[0]
    allow_ssh = "true"
    network_name = dependency.vpc.outputs.network_name
    region = dependency.vpc.outputs.private_subnetworks_region[0]
}
