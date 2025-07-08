module "tyler-module-test" {
  source                 = "./RVM"
  repository_name        = "tyler-test"
  repository_description = "tyler-test"
  pat                    = var.pat
  github_token           = var.github_token
}
