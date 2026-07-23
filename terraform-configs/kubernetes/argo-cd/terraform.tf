terraform {
  required_version = "~>1.15.0"
  backend "consul" {
    address = "192.168.1.2:8500"
    scheme  = "http"
    path    = "terraform-configs/kubernetes/argo-cd"
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
