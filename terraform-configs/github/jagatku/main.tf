#trivy:ignore:AVD-GIT-0001
resource "github_repository" "jagatku" {
  name                   = "jagatku"
  allow_merge_commit     = false
  allow_rebase_merge     = false
  allow_squash_merge     = true
  delete_branch_on_merge = true
  has_issues             = true
  has_projects           = true
  has_wiki               = true

  #checkov:skip=CKV_GIT_1
}

#trivy:ignore:AVD-GIT-0004
resource "github_branch_protection" "main" {
  repository_id  = github_repository.jagatku.node_id
  pattern        = "main"
  enforce_admins = true

  #checkov:skip=CKV_GIT_5
  #checkov:skip=CKV_GIT_6
}


resource "github_repository_vulnerability_alerts" "this" {
  repository = github_repository.jagatku.name
  enabled    = true
}
