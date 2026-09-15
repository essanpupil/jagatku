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

terraform {
    source = "git::https://github.com/essanpupil/iac-modules.git//gcp/secret-manager?ref=v0.0.6"
    # source = "/Users/essan/Code/iac-modules/gcp/secret-manager"
}

inputs = {
    secret_name = "keycloak_config"
  project_id         = dependency.project.outputs.project_id
}
