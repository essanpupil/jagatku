terraform {
  backend "consul" {
    address = "192.168.1.2:8500"
    scheme  = "http"
    path    = "terraform-configs/grafana/datasource/loki-local"
  }
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "4.40.1"
    }
  }
}

provider "grafana" {
  url  = "http://192.168.1.2:3000/"
  auth = var.grafana_auth
}
