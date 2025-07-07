terraform {
  required_version = ">= 1.12.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }

  backend "gcs" {
    bucket = "easinfra-tfstate-bucket"
    prefix = "terraform/state/ty-demo"
  }
}
provider "github" {

}