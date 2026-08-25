resource "vault_pki_secret_backend_role" "intermediate_role" {
  backend          = data.terraform_remote_state.intermediate_ca.outputs.pki_path
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

resource "kubernetes_manifest" "cert_issuer" {
  manifest = yamldecode(<<EOF
    apiVersion: cert-manager.io/v1
    kind: Issuer
    metadata:
      name: ${local.cert_issuer_name}
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
    spec:
      vault:
        server: http://vault.laptop1.local
        path: ${data.terraform_remote_state.intermediate_ca.outputs.pki_path}
        auth:
          kubernetes:
            mountPath: ${data.terraform_remote_state.kubernetes_vault.outputs.kubernetes_path}
            role: ${vault_pki_secret_backend_role.intermediate_role.name}
            secretRef:
              name: ${local.service_account_token_name}
              key: token
  EOF
  )
}

resource "kubernetes_manifest" "backstage_cert" {
  manifest = yamldecode(<<EOF
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: backstage-jagatku-local
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
    spec:
      secretName: backstage-jagatku-local-tls
      issuerRef:
        name: ${local.cert_issuer_name}
      commonName: backstage.jagatku.local
      dnsNames:
        - backstage.jagatku.local
  EOF
  )
}
