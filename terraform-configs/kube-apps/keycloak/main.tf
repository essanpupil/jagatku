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

resource "kubernetes_cluster_role_binding_v1" "keycloak" {
  metadata {
    name = "keycloak-vault"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.keycloak_sa.metadata[0].name
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
    type = "LoadBalancer"
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

resource "kubernetes_manifest" "keycloak_dep" {
  manifest = yamldecode(<<EOF
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: keycloak-dep
      namespace: keycloak
      labels:
        app: keycloak
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: keycloak
      template:
        metadata:
          labels:
            app: keycloak
        spec:
          containers:
            - name: keycloak
              image: quay.io/keycloak/keycloak:26.7.2
              args:
                - start
              env:
                - name: KC_HOSTNAME_ADMIN
                  value: "http://keycloak.jagat.local"
                - name: KC_HOSTNAME
                  value: "http://keycloak.${kubernetes_namespace_v1.this.metadata[0].name}.svc.cluster.local"
                - name: KC_FEATURES_DISABLED
                  value: "twitter-broker,identity-brokering-api"
                - name: KC_HTTP_ENABLED
                  value: true
                - name: KC_PROXY_HEADERS
                  value: "xforwarded"
                - name: KC_DB
                  value: "postgres"
                - name: KC_DB_PASSWORD
                  valueFrom:
                    secretKeyRef:
                      name: ${local.app_secret_name}
                      key: password
                - name: KC_DB_USERNAME
                  valueFrom:
                    secretKeyRef:
                      name: ${local.app_secret_name}
                      key: username
                - name: KC_DB_URL
                  value: "jdbc:postgresql://${local.db_cluster_name}-rw.${kubernetes_namespace_v1.this.metadata[0].name}.svc.cluster.local:5432/${local.db_name}"
              ports:
                - containerPort: 9000
                  name: heatlh
                - containerPort: 8080
                  name: http
                - containerPort: 7800
                  name: jgroups
                - containerPort: 57800
                  name: jgroups-fd
  EOF
  )
}
