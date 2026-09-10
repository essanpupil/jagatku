include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  project_config = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
  project_id     = local.project_config.locals.project_id
}

terraform {
  source = "/Users/essan/Code/iac-modules/gcp/vpc"
}
