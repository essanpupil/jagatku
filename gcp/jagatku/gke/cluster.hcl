locals {
    cluster_name = "jagat-kube-dev"
    service_account_id = "jagat-kube-dev"
    location = "us-east1"
}

generate "cluster_provider" {
    path = "cluster_provider.tf"
    if_exists = "overwrite_terragrunt"
    contents = <<EOF
data "google_client_config" "provider" {}

data "google_container_cluster" "my_cluster" {
  project = "jagatku"
  name     = "${local.cluster_name}"
  location = "${local.location}"
}

provider "kubernetes" {
  host  = "https://$${data.google_container_cluster.my_cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes = {
    host                   = "https://$${data.google_container_cluster.my_cluster.endpoint}"
    token                  = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate,
    )
  }
}
EOF
}
