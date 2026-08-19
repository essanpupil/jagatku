data "vault_policy_document" "this" {
  rule {
    path         = "secret/data/backstage/*"
    capabilities = ["read", "list"]
    description  = "Grafana auth from cicd"
  }
}
