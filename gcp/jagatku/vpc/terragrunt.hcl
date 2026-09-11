include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  project_config = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  project_id   = local.project_config.locals.project_id
  project_name = local.project_config.locals.project_name
  network_name = "vpc-dev"
  subnets      = [
    {
      name          = "priv-jagatku"
      ip_cidr_range = "10.2.0.0/16"
      region        = "us-east1"
    }
  ]
}

terraform {
  source = "git::https://github.com/essanpupil/iac-modules.git//gcp/vpc?ref=v0.0.4"
  // source = "/Users/essan/Code/iac-modules/gcp/vpc"
}

inputs = {
  network_name = "${local.project_name}-${local.network_name}"
  project_id = local.project_id
  private_subnets      = local.subnets
}
