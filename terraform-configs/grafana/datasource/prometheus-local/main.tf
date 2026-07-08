resource "grafana_data_source" "this" {
  type = "prometheus"
  name = "Prometheus-Local"
  url  = "http://localhost:9090"
  json_data_encoded = jsonencode(
    {
      tlsAuth           = false
      tlsAuthWithCACert = false
    }
  )
}

import {
  to = grafana_data_source.this
  id = "dfqgw3rsao6bkf"
}
