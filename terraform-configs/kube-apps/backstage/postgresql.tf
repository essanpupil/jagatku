resource "kubernetes_manifest" "db_cluster" {
  manifest = yamldecode(<<EOF
        apiVersion: postgresql.cnpg.io/v1
        kind: Cluster
        metadata:
            name: backstage-db-cluster
            namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
        spec:
            instances: 3
            storage:
                size: 1Gi
    EOF
  )
}
