resource "github_repository" "repository" {

  name        = var.repository_name
  description = var.repository_description
  visibility  = "private"
  auto_init   = true
}

resource "kubernetes_service_account" "tf_plan_prod" {
  metadata {
    name      = "tf-harness-demo"
    namespace = "ty-demo"
  }
}
