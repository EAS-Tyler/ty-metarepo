terraform {
  required_providers {
    harness = {
      source  = "harness/harness"
      version = "0.37.5"
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