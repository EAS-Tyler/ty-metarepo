module "tyler-module-test" {
  source                 = "./RVM"
  repository_name        = "tyler-test9999"
  repository_description = "tyler-test999"
  pat                    = var.pat
  github_token           = var.github_token
}
