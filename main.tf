module "tyler-module-test" {
  source                 = "./RVM"
  repository_name        = "tyler-test99"
  repository_description = "tyler-test99"
  pat                    = var.pat
  github_token           = var.github_token
}
