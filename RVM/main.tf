# GITHUB
resource "github_repository" "repository" {
  name        = var.repository_name
  description = var.repository_description
  visibility  = "private"
  auto_init   = true
}

# KUBERNETES

resource "kubernetes_namespace" "k8s-ns" {
  metadata {
    name = "${var.repository_name}-ns"
  }
}

resource "kubernetes_service_account" "k8s-sa" {
  metadata {
    name      = "${var.repository_name}-sa"
    namespace = kubernetes_namespace.k8s-ns.metadata[0].name
  }
}

resource "kubernetes_role" "k8s-role" {
  metadata {
    name      = "${var.repository_name}-role"
    namespace = kubernetes_service_account.k8s-sa.metadata[0].namespace
  }
  rule {
    api_groups = [""]
    resources = ["pods"]
    verbs     = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding" "k8s-role-binding" {
  metadata {
    name      = "${var.repository_name}-role-binding"
    namespace = kubernetes_service_account.k8s-sa.metadata[0].namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.k8s-role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.k8s-sa.metadata[0].name
    namespace = kubernetes_service_account.k8s-sa.metadata[0].namespace
  }
}

# HARNESS
resource "harness_platform_project" "project" {  
    name      = "${var.repository_name}-project"
    identifier = replace(var.repository_name, "-", "_")
    org_id    = "default"  
}

