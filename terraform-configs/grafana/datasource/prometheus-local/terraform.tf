terraform {
  backend "consul" {
    address = "192.168.1.2:8500"
    scheme  = "http"
    path    = "terraform-configs/grafana/datasource/prometheus-local"
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "5.10.1"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "4.40.1"
    }
  }
}

provider "vault" {
  address = "http://192.168.1.2:8200"
  auth_login_userpass {}
}

provider "grafana" {
  url  = "http://192.168.1.2:3000/"
  auth = data.vault_kv_secret_v2.grafana_secrets.data["token"]
}

data "vault_kv_secret_v2" "grafana_secrets" {
  mount = "secret"
  name  = "devops/grafana/creds"
}
