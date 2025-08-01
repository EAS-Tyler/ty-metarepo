variable "repository_name" {
  type = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.repository_name))
    error_message = "The repository name can only contain lower case letters, numbers or hyphens"
  }
}

variable "repository_description" {
  type = string
}
variable "pat" {
  description = "Harness Platform API Key"
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "The GitHub token."
  type        = string
  sensitive   = true
}