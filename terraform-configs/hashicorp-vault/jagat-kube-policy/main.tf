resource "vault_policy" "this" {
  name = "backstage-jagat"

  policy = <<EOT
path "secret/data/backstage/*" {
  capabilities = ["read"]
}
EOT
}
