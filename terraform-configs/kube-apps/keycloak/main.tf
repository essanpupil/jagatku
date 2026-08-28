resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = "keycloak"
  }
}

resource "kubernetes_service_account_v1" "keycloak_sa" {
  metadata {
    name      = local.service_account_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
}

resource "kubernetes_service_v1" "keycloak" {
  metadata {
    name      = "keycloak"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  spec {
    selector = {
      app = "keycloak"
    }
    port {
      port        = 8080
      target_port = 80
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_service_v1" "keycloak_discovery" {
  metadata {
    name      = "keycloak-discovery"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
  spec {
    selector = {
      app = "keycloak"
    }
    cluster_ip = "None"
    type       = "ClusterIP"
  }
}

resource "kubernetes_stateful_set_v1" "keycloak" {
  metadata {
    labels = {
      app = "keycloak"
    }
    name      = "keycloak"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  spec {
    service_name = kubernetes_service_v1.keycloak_discovery.metadata[0].name
    replicas     = "2"

    selector {
      match_labels = {
        app = "keycloak"
      }
    }

    template {
      metadata {
        labels = {
          app = "keycloak"
        }
      }

      spec {
        container {
          name  = "keycloak"
          image = "quay.io/keycloak/keycloak:26.7.2"
          args  = ["start"]

          port {
            container_port = 8080
            name           = "http"
          }
          port {
            container_port = 7800
            name           = "jgroups"
          }
          port {
            container_port = 57800
            name           = "jgroups-fd"
          }

          env {
            name  = "KC_BOOTSTRAP_ADMIN_USERNAME"
            value = "admin"
          }
          env {
            name  = "KC_BOOTSTRAP_ADMIN_PASSWORD"
            value = "admin"
          }
          env {
            name  = "KC_PROXY_HEADERS"
            value = "xforwarded"
          }
          env {
            name  = "KC_HTTP_ENABLED"
            value = "true"
          }
          env {
            name  = "KC_HOSTNAME_STRICT"
            value = "false"
          }
          env {
            name  = "KC_HEALTH_ENABLED"
            value = "true"
          }
          env {
            name  = "KC_CACHE"
            value = "ispn"
          }
          env {
            name = "POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }
          env {
            name  = "KC_CACHE_EMBEDDED_NETWORK_BIND_ADDRESS"
            value = "$(POD_IP)"
          }
          env {
            name  = "KC_DB_URL_DATABASE"
            value = "keycloak"
          }
          env {
            name  = "KC_DB_URL_HOST"
            value = "postgres"
          }
          env {
            name  = "KC_DB"
            value = "postgres"
          }
          env {
            name  = "KC_DB_PASSWORD"
            value = "keycloak"
          }
          env {
            name  = "KC_DB_USERNAME"
            value = "keycloak"
          }

          startup_probe {
            http_get {
              path = "/health/started"
              port = 9000
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          readiness_probe {
            http_get {
              path = "/health/ready"
              port = 9000
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          liveness_probe {
            http_get {
              path   = "/health/live"
              port   = 9090
              scheme = "HTTPS"
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }
        }
      }
    }
  }
}

import {
  to = kubernetes_stateful_set_v1.keycloak
  id = "keycloak/keycloak"
}
