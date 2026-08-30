resource "kubernetes_manifest" "db_cluster" {
  manifest = yamldecode(<<EOF
        apiVersion: postgresql.cnpg.io/v1
        kind: Cluster
        metadata:
            name: ${local.db_cluster_name}
            namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
        spec:
            instances: 3
            bootstrap:
                initdb:
                    database: backstage_db
                    owner: ${local.db_username}
                    secret:
                        name: ${local.secret_name}
            storage:
                size: 1Gi
    EOF
  )
}
