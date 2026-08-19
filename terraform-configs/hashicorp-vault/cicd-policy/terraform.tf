terraform {
  required_version = "~>1.15.0"
  backend "consul" {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/hashicorp-vault/cicd-policy"
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "5.10.1"
    }
  }
}

# This config require root level permission, hence the auth method used is different compare to other
# terraform vault config
provider "vault" {
  address          = "http://vault.laptop1.local"
  skip_child_token = true
  auth_login_token_file {
    filename = "/Users/essan/.vault_pass"
  }
}
