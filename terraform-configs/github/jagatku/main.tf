resource "github_repository" "jagatku" {
  name = "jagatku"
}

import {
  to = github_repository.jagatku
  id = "jagatku"
}
