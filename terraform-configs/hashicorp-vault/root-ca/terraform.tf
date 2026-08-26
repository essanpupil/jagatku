terraform {
  required_version = "~>1.15.0"
  backend "consul" {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/hashicorp-vault/root-ca"
  }

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "5.10.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.1"
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

provider "kubernetes" {
  config_path = "~/.kube/config"
}
