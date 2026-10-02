variable "project_id" {
  description = "GCP project"
  type        = string
}

variable "region" {
  description = "Primary region"
  type        = string
  default     = "us-east1"
}

variable "github_owner" {
  description = "GitHub account allowed to authenticate"
  type        = string
}

variable "tfstate_bucket" {
  description = "Terraform state bucket. Created during manual bootstrap, outside this code."
  type        = string
}

variable "api_service_name" {
  description = "Cloud Run service name, used to derive its runtime service account name"
  type        = string
  default     = "alejoavila-api"
}

variable "hosting_site_id" {
  description = "Firebase Hosting site identifier. Defines the <site_id>.web.app subdomain and is globally unique, not just within the project."
  type        = string
  default     = "alejoavila"

  validation {
    condition     = var.hosting_site_id != "alejoavila-web"
    error_message = "Do not reuse the project id: Firebase already creates a default site with that name and the apply would collide."
  }

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$", var.hosting_site_id))
    error_message = "Must be 3 to 30 characters, lowercase letters, digits and hyphens only, not starting or ending with a hyphen."
  }
}
