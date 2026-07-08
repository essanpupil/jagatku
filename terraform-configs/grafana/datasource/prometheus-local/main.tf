resource "grafana_data_source" "this" {
  type                = "loki"
  name                = "Prometheus-Local"
}

import {
    to = grafana_data_source.this
    id = "dfqgw3rsao6bkf"
}
