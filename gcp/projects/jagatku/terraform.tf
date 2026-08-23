terraform {
  required_version = "~>1.15.0"
  backend "consul" {
    address = "consul.laptop1.local"
    scheme  = "http"
    path    = "gcp/projects/jagatku"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.45"
    }
  }
}

provider "google" {
  region  = "us-central1"
  project = "jagatku"
}
