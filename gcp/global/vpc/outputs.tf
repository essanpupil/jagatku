output "network_id" {
  value = google_compute_network.jagat.id
}

output "subnetwork_id" {
  value = google_compute_subnetwork.private_subnetwork.id
}
