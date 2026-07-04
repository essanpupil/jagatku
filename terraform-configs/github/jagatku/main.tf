resource "github_repository" "jagatku" {
  name               = "jagatku"
  allow_merge_commit = false
  allow_rebase_merge = false
  allow_squash_merge = false
  has_issues         = true
  has_projects       = true
  has_wiki           = true
}

import {
  to = github_repository.jagatku
  id = "jagatku"
}
