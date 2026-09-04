terraform {
  backend "consul" {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/github/backstage"
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
  required_version = "~> 1.15.6"
}

provider "github" {
  owner = "essanpupil"
  token = var.token
}
