resource "vault_policy" "this" {
  name   = local.vault_policy_name
  policy = data.vault_policy_document.this.hcl
}

resource "vault_kubernetes_auth_backend_role" "this" {
  backend                          = data.terraform_remote_state.vault_common.outputs.kubernetes_path
  role_name                        = "keycloak-app-role"
  bound_service_account_names      = [kubernetes_service_account_v1.keycloak_sa.metadata[0].name]
  bound_service_account_namespaces = [kubernetes_namespace_v1.this.metadata[0].name]
  token_policies                   = [vault_policy.this.name]
  token_ttl                        = 1800 # 30 minutes
}

resource "vault_kv_secret_v2" "superuser_passwd" {
  mount = data.terraform_remote_state.vault_common.outputs.kv_secret_path
  name  = local.superuser_secret_name

  data_json = jsonencode({
    username = "postgres"
    password = "PleaseChangeMe" # checkov:skip=CKV_SECRET_6 will be changed in vault web ui
  })
}

resource "vault_kv_secret_v2" "app_passwd" {
  mount = data.terraform_remote_state.vault_common.outputs.kv_secret_path
  name  = local.app_secret_name

  data_json = jsonencode({
    username = local.db_username
    password = "PleaseChangeMe" # checkov:skip=CKV_SECRET_6 will be changed in vault web ui
  })
}

resource "kubernetes_manifest" "vault_auth" {
  manifest = yamldecode(<<EOF
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultAuth
    metadata:
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
      name: keycloak-vault-auth
    spec:
      # required configuration
      # VaultConnectionRef of the corresponding VaultConnection CustomResource.
      # If no value is specified the Operator will default to the `default` VaultConnection,
      # configured in its own Kubernetes namespace.
      # vaultConnectionRef: vault-connection
      # Method to use when authenticating to Vault.
      method: kubernetes
      # Mount to use when authenticating to auth method.
      mount: kubernetes
      # Kubernetes specific auth configuration, requires that the Method be set to kubernetes.
      kubernetes:
        # role to use when authenticating to Vault
        role: ${vault_kubernetes_auth_backend_role.this.role_name}
        # ServiceAccount to use when authenticating to Vault
        # it is recommended to always provide a unique serviceAccount per Pod/application
        serviceAccount: ${kubernetes_service_account_v1.keycloak_sa.metadata[0].name}

      # optional configuration
      # Vault namespace where the auth backend is mounted (requires Vault Enterprise)
      # namespace: ""
      # Params to use when authenticating to Vault
      # params: []
      # HTTP headers to be included in all Vault authentication requests.
      # headers: []
  EOF
  )
}

resource "kubernetes_manifest" "superuser_secret" {
  manifest = yamldecode(<<EOF
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultStaticSecret
    metadata:
      namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
      name: ${local.superuser_secret_name}
    spec:
      vaultAuthRef: keycloak-vault-auth
      mount: ${data.terraform_remote_state.vault_common.outputs.kv_secret_path}
      type: kv-v2
      path: ${local.superuser_secret_name}
      version: 2
      refreshAfter: 10s
      destination:
        create: true
        name: ${local.superuser_secret_name}
        overwrite: true
        type: kubernetes.io/basic-auth
    EOF
  )
}

# resource "kubernetes_manifest" "keycloak_app_secret" {
#   manifest = yamldecode(<<EOF
#     apiVersion: secrets.hashicorp.com/v1beta1
#     kind: VaultStaticSecret
#     metadata:
#       namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
#       name: ${local.app_secret_name}
#     spec:
#       mount: ${data.terraform_remote_state.vault_common.outputs.kv_secret_path}
#       type: kv-v2
#       path: ${local.app_secret_name}
#       version: 2
#       refreshAfter: 10s
#       destination:
#         create: true
#         name: ${local.app_secret_name}
#         overwrite: true
#         type: kubernetes.io/basic-auth
#     EOF
#   )
# }

# resource "kubernetes_manifest" "cnfg" {
#   manifest = yamldecode(<<EOF
#     apiVersion: postgresql.cnpg.io/v1
#     kind: Cluster
#     metadata:
#       name: ${local.db_cluster_name}
#       namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
#     spec:
#       serviceAccountName: ${kubernetes_service_account_v1.keycloak_sa.metadata[0].name}
#       instances: 3
#       storage:
#         size: 1Gi
#       bootstrap:
#         initdb:
#           database: ${local.db_name}
#           owner: ${local.db_username}
#           secret:
#             name: ${local.app_secret_name}
#       enableSuperuserAccess: true
#       superuserSecret:
#         name: ${local.superuser_secret_name}
#   EOF
#   )
# }

# resource "kubernetes_manifest" "keycloak_db_app_role" {
#   manifest = yamldecode(<<EOF
#     apiVersion: postgresql.cnpg.io/v1
#     kind: DatabaseRole
#     metadata:
#       name: keycloak-app-role
#       namespace: ${kubernetes_namespace_v1.this.metadata[0].name}
#     spec:
#       cluster:
#         name: ${local.db_cluster_name}
#       name: ${local.db_username}
#       login: true
#       superuser: false
#       createdb: true
#       databaseRoleReclaimPolicy: delete
#       inRoles:
#         - pg_monitor
#       passwordSecret:
#         name: ${local.app_secret_name}
#   EOF
#   )
# }
