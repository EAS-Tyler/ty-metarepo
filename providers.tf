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

  }

  backend "gcs" {
    bucket = "easinfra-tfstate-bucket"
    prefix = "terraform/state/ty-demo"
  }
}
provider "github" {
}

provider "harness" {
  endpoint         = "https://app.harness.io/gateway"
  account_id       = "3gVpG6oMRf6AINkET4hUuw"
  platform_api_key = var.pat
}

# provider "kubernetes" {
#   config_path    = "~/.kube/config"
#   config_context = "minikube"
# }