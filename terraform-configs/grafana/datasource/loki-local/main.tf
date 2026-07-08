resource "grafana_data_source" "this" {
  type                = "loki"
  name                = "loki-local"
}

import {
    to = grafana_data_source.this
    id = "Loki-Local"
}
