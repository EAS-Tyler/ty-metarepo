terraform {
  required_version = ">= 1.12.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }

    harness = {
      source  = "harness/harness"
      version = "0.37.5"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }

  }

  # backend "gcs" {
  #   bucket = "easinfra-tfstate-bucket"
  #   prefix = "terraform/state/ty-demo"
  # }
}

# provider "kubernetes" {
#   config_path    = "~/.kube/config"
#   config_context = "minikube"
# }


