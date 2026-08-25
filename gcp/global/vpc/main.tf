resource "google_compute_network" "jagat" {
  # checkov:ignore:CKV2_GCP_18
  name                    = "jagat"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_firewall" "allow_web" {
  name          = "jagat-allow-web"
  network       = google_compute_network.jagat.name
  source_ranges = ["10.2.0.0/16"]
  source_tags   = ["jagat"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_subnetwork" "private_subnetwork" {
  name                     = "private-subnetwork"
  ip_cidr_range            = "10.2.0.0/16"
  region                   = "us-central1"
  network                  = google_compute_network.jagat.id
  private_ip_google_access = true


  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
