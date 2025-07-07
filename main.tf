module "tyler-module-test" {
  source                 = "./RVM"
  repository_name        = "tyler-module-test"
  repository_description = "tyler-module-test"
}

module "tyler-module-test-2" {
  source                 = "./RVM"
  repository_name        = "tyler-module-test-2"
  repository_description = "tyler-module-test-2"
}
