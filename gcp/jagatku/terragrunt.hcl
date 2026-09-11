include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  project_config = read_terragrunt_config("project.hcl")
  project_id     = local.project_config.locals.project_id
  project_name   = local.project_config.locals.project_name
}

terraform {
  source = "git::https://github.com/essanpupil/iac-modules.git//gcp/jagatku?ref=v0.0.3"
}

inputs = {
  project_name    = local.project_name
  project_id      = local.project_id
  billing_account = "017F7F-B8D025-803DAC"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
  project = "${local.project_id}"
}

provider "google-beta" {
  project = "${local.project_id}"
}
EOF
}
