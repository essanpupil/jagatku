resource "vault_pki_secret_backend_role" "intermediate_role" {
  backend          = data.terraform_remote_state.vault_common.outputs.pki_int_path
  issuer_ref       = data.terraform_remote_state.intermediate_ca.outputs.issuer_ref
  name             = "backstage-jagatku-local"
  ttl              = 86400
  max_ttl          = 2592000
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["jagatku.local"]
  allow_subdomains = true
}

resource "vault_pki_secret_backend_cert" "backstage_jagatku_local" {
  issuer_ref  = data.terraform_remote_state.intermediate_ca.outputs.issuer_ref
  backend     = vault_pki_secret_backend_role.intermediate_role.backend
  name        = vault_pki_secret_backend_role.intermediate_role.name
  common_name = "backstage.jagatku.local"
  ttl         = 3600
  revoke      = true
}

resource "kubernetes_manifest" "backstage_cert" {
  manifest = yamldecode(<<EOF
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: backstage-jagatku-local
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
    spec:
      secretName: ${local.tls_secret_name}
      duration: 48h
      renewBefore: 5h
      issuerRef:
        name: "dummy"
        kind: ClusterIssuer
      commonName: backstage.jagatku.local
      dnsNames:
        - backstage.jagatku.local
      privateKey:
        algorithm: RSA
        size: 4096
        rotationPolicy: Always
  EOF
  )
}
