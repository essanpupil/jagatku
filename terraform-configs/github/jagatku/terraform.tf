terraform {
  backend "consul" {
    address = "192.168.1.2:8500"
    scheme  = "http"
    path    = "terraform-configs/github/jagatku"
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = "essanpupil"
  token = var.token
}
