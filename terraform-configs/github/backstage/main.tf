module "repo" {
  # checkov:skip=CKV_TF_1: I owned the remote repo, safe to use tag as ref
  source          = "git::https://github.com/essanpupil/iac-modules.git//github/repository?ref=v0.0.2"
  repository_name = "backstage"
}

import {
  to = module.repo.github_repository.this
  id = "backstage"
}
