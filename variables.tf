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