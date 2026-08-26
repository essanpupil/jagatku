resource "vault_mount" "kvv2" {
  path = "sensitive-data"
  type = "kv-v2"
  options = {
    version = "2"
  }
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes"
}

resource "vault_mount" "pki" {
  path        = "pki"
  type        = "pki"
  description = "PKI mount for https certs"

  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 315360000
}

resource "vault_mount" "pki_int" {
  path        = "pki_int"
  type        = "pki"
  description = "intermediate PKI mount"

  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 157680000
}

import {
  to = vault_mount.pki
  id = "pki"
}

import {
  to = vault_mount.pki_int
  id = "pki_int"
}
