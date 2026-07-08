resource "grafana_data_source" "this" {
  type = "loki"
  name = "Loki-Local"
  url  = "http://localhost:3100"
  http_headers = {
    "X-Scope-OrgID" = "fake"
  }

  json_data_encoded = jsonencode(
    {
      tlsAuth           = false
      tlsAuthWithCACert = false
    }
  )
}

import {
  to = grafana_data_source.this
  id = "afqh58e2dhm9sc"
}
