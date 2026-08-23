resource "google_service_account" "pemangku" {
  account_id   = local.service_account_id
  display_name = "Pemangku Jagat"
}

resource "google_container_cluster" "jagatku" {
  # checkov:skip=CKV_GCP_69
  # checkov:skip=CKV_GCP_65
  name                     = "jagatku"
  location                 = "us-central1"
  remove_default_node_pool = true
  initial_node_count       = 1
  networking_mode          = "VPC_NATIVE"
  network                  = data.terraform_remote_state.vpc.outputs.network_id
  subnetwork               = data.terraform_remote_state.vpc.outputs.subnetwork_id
  deletion_protection      = false

  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  resource_labels = {
    "managedby" = "terraform"
  }

  workload_identity_config {
    workload_pool = "jagatku.svc.id.goog"
  }

  release_channel {
    channel = "REGULAR"
  }

  enable_intranode_visibility = true

  ip_allocation_policy {}

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  private_cluster_config {
    enable_private_nodes = true
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # authenticator_groups_config {
  #   security_group = "gke-security-groups@jagatku.com"
  # }

  master_authorized_networks_config {
    gcp_public_cidrs_access_enabled      = false
    private_endpoint_enforcement_enabled = true
  }
}

resource "google_container_node_pool" "primary" {
  # checkov:skip=CKV_GCP_69
  name       = "jagatku"
  location   = "us-central1"
  cluster    = google_container_cluster.jagatku.name
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = "e2-small"
    preemptible     = true
    service_account = google_service_account.pemangku.email
    image_type      = "COS_CONTAINERD"

    metadata = {
      disable-legacy-endpoints = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }
}
