locals {
  service_account_name        = "cert-manager-kube-sa"
  service_account_secret_name = "cert-manager-token"
  pki_role_name               = "cert-manager-vault-pki-role"
  allowed_domains             = ["jagatku.local"]
  kubernetes_vault_role       = "vault-cert-issuer"
  cluster_issuer_name         = "issuer-cert-man"
}
