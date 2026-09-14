include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  project_config = read_terragrunt_config("project.hcl")
}

terraform {
  source = "git::https://github.com/essanpupil/iac-modules.git//gcp/jagatku?ref=v0.0.6"
  # source = "/Users/essan/Code/iac-modules/gcp/project"
}

inputs = {
  project_name    = local.project_config.locals.project_name
  project_id      = local.project_config.locals.project_id
  billing_account = "017F7F-B8D025-803DAC"
  enabled_services = [
    "secretmanager.googleapis.com"
  ]
}
