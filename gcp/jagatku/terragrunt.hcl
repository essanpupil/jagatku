include {
  path = find_in_parent_folders("root.hcl")
}

locals {
    project_id = "jagatku"
    project_name = "jagatku"
}

terraform {
  source = "/Users/essan/Code/iac-modules/gcp/jagatku"
}

inputs = {
  project_name = local.project_name
  project_id   = local.project_id
}

generate "imports" {
  path      = "imports.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    import {
      to = google_project.this
      id = "${local.project_id}"
    }
  EOF
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
