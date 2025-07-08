module "tyler-module-test" {
  source                 = "./RVM"
  repository_name        = "tyler-module-test"
  repository_description = "tyler-module-test"
  pat                    = var.pat
  github_token           = var.github_token
}
