resource "helm_release" "this" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  namespace  = "kube-system"
  version    = "1.19.6"
  atomic     = true
  wait       = true
  values = [
    file("${path.module}/values.yaml")
  ]
}

import {
  to = helm_release.this
  id = "kube-system/cilium"
}