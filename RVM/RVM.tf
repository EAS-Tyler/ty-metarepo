resource "github_repository" "repository" {

  name        = var.repository_name
  description = var.repository_description
  visibility  = "private"
  auto_init   = true
}
