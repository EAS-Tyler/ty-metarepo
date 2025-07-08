terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = "0.37.5"
    }
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
  backend "gcs" {
    bucket = "easinfra-tfstate-bucket"
    prefix = "terraform/state/ty-metarepo"
  }
}

provider "harness" {
  endpoint         = "https://app.harness.io/gateway"
  account_id       = "3gVpG6oMRf6AINkET4hUuw"
  platform_api_key = var.pat
}

provider "github" {
  token = var.github_token
}

# provider "kubernetes" {
#   config_path    = "~/.kube/config"
#   config_context = "minikube"
# }