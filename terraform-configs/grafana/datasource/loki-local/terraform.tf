terraform {
  required_version = "~>1.15.0"
  backend "consul" {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "terraform-configs/grafana/datasource/loki-local"
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
  address          = "http://vault.laptop1.local"
  skip_child_token = true
  auth_login_userpass {}
}

provider "grafana" {
  url  = "http://grafana.laptop1.local"
  auth = tostring(ephemeral.vault_kv_secret_v2.grafana_secrets.data.grafana_api_key)
}

ephemeral "vault_kv_secret_v2" "grafana_secrets" {
  mount = "grafana-token"
  name  = "grafana_api_key"
}
