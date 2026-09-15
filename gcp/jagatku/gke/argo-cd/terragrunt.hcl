include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "cluster" {
  path = find_in_parent_folders("cluster.hcl")
}

dependencies {
    paths = [
        dirname(find_in_parent_folders("cluster.hcl"))
    ]
}

terraform {
    source = "git::https://github.com/essanpupil/iac-modules.git//kubernetes/helm?ref=v0.0.7"
    # source = "/Users/essan/Code/iac-modules/kubernetes/helm"
}

inputs = {
    chart_version = "10.9.1"
    repository = "https://argoproj.github.io/argo-helm"
    chart = "argo-cd"
    release_name = "argo-cd"
    create_namespace = true
    namespace_name = "argo-cd-system"
}
