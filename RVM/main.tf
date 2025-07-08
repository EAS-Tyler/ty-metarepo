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

resource "kubernetes_service_account_v1" "k8s-sa" {
  metadata {
    name      = "${var.repository_name}-sa"
    namespace = kubernetes_namespace.k8s-ns.metadata[0].name
  }
}

resource "kubernetes_role" "k8s-role" {
  metadata {
    name      = "${var.repository_name}-role"
    namespace = kubernetes_service_account_v1.k8s-sa.metadata[0].namespace
  }
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

resource "kubernetes_role_binding" "k8s-role-binding" {
  metadata {
    name      = "${var.repository_name}-role-binding"
    namespace = kubernetes_service_account_v1.k8s-sa.metadata[0].namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.k8s-role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.k8s-sa.metadata[0].name
    namespace = kubernetes_service_account_v1.k8s-sa.metadata[0].namespace
  }
}

resource "kubernetes_token_request_v1" "this" {
  metadata {
    name      = "${var.repository_name}-sa"
    namespace = kubernetes_namespace.k8s-ns.metadata[0].name
  }
  spec {
    audiences = [
      "api",
      "vault",
      "factors"
    ]
  }
}

# HARNESS
resource "harness_platform_project" "project" {
  name       = "${var.repository_name}-project"
  identifier = replace(var.repository_name, "-", "_")
  org_id     = "default"
}

resource "harness_platform_secret_text" "sa_token" {
  identifier                = "${var.repository_name}-sa-token"
  name                      = "${var.repository_name}-sa-token"
  description               = "Service account token for ${var.repository_name}"
  tags                      = ["env:${var.repository_name}"]
  project_id                = harness_platform_project.project.identifier
  org_id                    = "default"
  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = kubernetes_token_request_v1.this.token
}

resource "harness_platform_secret_text" "github_token" {
  identifier                = "${var.repository_name}-github-token"
  name                      = "${var.repository_name}-github-token"
  description               = "Service account token for ${var.repository_name}"
  tags                      = ["env:${var.repository_name}"]
  project_id                = harness_platform_project.project.identifier
  org_id                    = "default"
  secret_manager_identifier = "harnessSecretManager"
  value_type                = "Inline"
  value                     = var.github_token
}

resource "harness_platform_connector_kubernetes" "k8sconn" {
  name        = "${var.repository_name}-k8s"
  identifier  = replace(var.repository_name, "-", "_")
  description = "Kubernetes connector for ${var.repository_name}"
  project_id  = harness_platform_project.project.identifier
  org_id      = "default"
  inherit_from_delegate {
    delegate_selectors = ["helm-delegate"]
  }
}

resource "harness_platform_connector_github" "githubconn" {
  name        = "${var.repository_name}-github"
  identifier  = replace(var.repository_name, "-", "_")
  description = "GitHub connector for ${var.repository_name}"
  project_id  = harness_platform_project.project.identifier
  org_id      = "default"

  connection_type = "Repo"

  url = "https://github.com/EAS-Tyler/${var.repository_name}"
  # INTERPOLATE DEVS USERNAME ^^^^ 
  credentials {
    http {
      username  = "EAS-Tyler"
      token_ref = "project.${harness_platform_secret_text.github_token.identifier}"
    }
  }
}


# PIPELINE from template - pass in connector

resource "harness_platform_environment" "environment" {
  identifier = replace(var.repository_name, "-", "_")
  name       = "${var.repository_name}-environment"
  org_id     = "default"
  project_id = harness_platform_project.project.identifier
  type       = "PreProduction"
}


resource "harness_platform_service" "example" {
  identifier  = replace(var.repository_name, "-", "_")
  name        = "${var.repository_name}-service"
  description = "Service for ${var.repository_name}"
  org_id      = "default"
  project_id  = harness_platform_project.project.identifier
  yaml        = <<-EOT
              service:
                name: ${var.repository_name}-service
                identifier: ${replace(var.repository_name, "-", "_")}
                serviceDefinition:
                  type: Kubernetes
                  spec:
                    manifests:
                      - manifest:
                          identifier: ${replace(var.repository_name, "-", "_")}-manifest
                          type: K8sManifest
                          spec:
                            store:
                              type: Github
                              spec:
                                connectorRef: tyghconnector
                                gitFetchType: Branch
                                paths:
                                  - .
                                repoName: ${var.repository_name}
                                branch: main
                            skipResourceVersioning: false
                            enableDeclarativeRollback: false
                gitOpsEnabled: false
              EOT
}

resource "harness_platform_infrastructure" "example" {
  identifier      = replace(var.repository_name, "-", "_")
  name            = "${var.repository_name}-infrastructure"
  org_id          = "default"
  project_id      = harness_platform_project.project.identifier
  env_id          = harness_platform_environment.environment.identifier
  type            = "KubernetesDirect"
  deployment_type = "Kubernetes"

  yaml = <<-EOT
        infrastructureDefinition:
         name: ${var.repository_name}-infrastructure
         identifier: ${replace(var.repository_name, "-", "_")}
         description: "Infrastructure for ${var.repository_name}"
         orgIdentifier: default
         projectIdentifier: ${harness_platform_project.project.identifier}
         environmentRef: ${harness_platform_environment.environment.identifier}
         deploymentType: Kubernetes
         type: KubernetesDirect
         spec:
          connectorRef: account.${harness_platform_connector_kubernetes.k8sconn.identifier}
          namespace: ${kubernetes_namespace.k8s-ns.metadata[0].name}
          releaseName: release-${replace(var.repository_name, "-", "_")}
          allowSimultaneousDeployments: false
      EOT
}






# create service 
# create github connector

# resource "harness_platform_pipeline" "pipeline" {
#   identifier = replace(var.repository_name, "-", "_")
#   org_id     = "default"
#   project_id = harness_platform_project.project.identifier
#   name       = "${var.repository_name}-pipeline"
#   yaml       = file("${path.module}/pipeline.yaml")
# }


# what level in heirarchy do i want these created at? IN THE DEVS PROJECT

# output "k8s_connector_id" {
#   value = harness_platform_connector_kubernetes.k8sconn.identifier
# }
# output "harness_project_id" {
#   value = harness_platform_project.project.identifier
# }