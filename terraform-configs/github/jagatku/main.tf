resource "github_repository" "jagatku" {
  name               = "jagatku"
  allow_merge_commit = true
  allow_rebase_merge = true
  allow_squash_merge = true
  has_issues         = true
  has_projects       = true
  has_wiki           = true
}


import {
  to = github_repository.jagatku
  id = "jagatku"
}
