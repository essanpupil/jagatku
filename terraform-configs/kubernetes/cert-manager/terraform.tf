terraform {
  required_version = "~>1.15.0"
  backend "consul" {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/kubernetes/cert-manager"
  }

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "5.11"
    }
  }
}

provider "vault" {
  address          = "http://vault.laptop1.local"
  skip_child_token = true
  auth_login_token_file {
    filename = pathexpand("~/.vault_pass")
  }
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
