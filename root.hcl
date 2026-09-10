generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "consul" {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "${path_relative_to_include()}"
  }
}
EOF
}
