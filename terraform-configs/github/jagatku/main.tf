#trivy:ignore:AVD-GIT-0001
resource "github_repository" "jagatku" {
  name               = "jagatku"
  allow_merge_commit = true
  allow_rebase_merge = true
  allow_squash_merge = true
  has_issues         = true
  has_projects       = true
  has_wiki           = true

  #checkov:skip=CKV_GIT_3
  #checkov:skip=CKV_GIT_1
}


resource "github_repository_vulnerability_alerts" "this" {
  repository = github_repository.jagatku.name
  enabled    = true
}
