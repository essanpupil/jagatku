resource "grafana_data_source" "this" {
  type                = "loki"
  name                = "Loki-Local"
}

import {
    to = grafana_data_source.this
    id = "afqh58e2dhm9sc"
}
