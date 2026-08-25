# trivy:ignore:GCP-0079
resource "google_project" "jagatku" {
  # checkov:ignore:CKV2_GCP_5
  name                = "jagatku"
  project_id          = "jagatku"
  billing_account     = "017F7F-B8D025-803DAC"
  auto_create_network = false
}

import {
  id = "jagatku"
  to = google_project.jagatku
}

output "project_id" {
  value = google_project.jagatku.project_id
}
