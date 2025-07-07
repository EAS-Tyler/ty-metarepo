resource "github_repository" "repository" {

  name        = var.repository_name
  description = var.repository_description
  visibility  = "private"
  auto_init   = true
}

resource "kubernetes_service_account" "tf_plan_prod" {
  metadata {
    name      = "tf-harness-demo2"
    namespace = "ty-demo"
  }
}

# names need to be dyanmic!
resource "kubernetes_role" "example_role" {
  metadata {
    name = "example-role"
    namespace = "default"
  }
  rule {
    api_groups = [""]
    resources = ["pods"]
    verbs = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding" "example_role_binding" {
  metadata {
    name = "example-role-binding"
    namespace = "default"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = kubernetes_role.example_role.metadata[0].name
  }
  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account.tf_plan_prod.metadata[0].name
    namespace = "default"
  }
}