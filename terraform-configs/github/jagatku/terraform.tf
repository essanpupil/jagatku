terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = "essanpupil"
  token = var.token # or `GITHUB_TOKEN`
}
