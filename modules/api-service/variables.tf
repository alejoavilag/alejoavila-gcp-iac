variable "project_id" {
  description = "GCP project"
  type        = string
}

variable "region" {
  description = "Region for Cloud Run and Artifact Registry"
  type        = string
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
}

variable "runtime_service_account_email" {
  description = "Identity the container runs as. Created in the bootstrap layer."
  type        = string

  validation {
    condition     = can(regex("^[^@]+@[^.]+\\.iam\\.gserviceaccount\\.com$", var.runtime_service_account_email))
    error_message = "Must be a GCP service account email."
  }

  validation {
    condition     = !can(regex("^[0-9]+-compute@developer\\.gserviceaccount\\.com$", var.runtime_service_account_email))
    error_message = "Do not use the default Compute service account: it carries editor permissions across the whole project."
  }
}

variable "repository_id" {
  description = "Artifact Registry repository name"
  type        = string
}

variable "image" {
  description = "Initial image. CI replaces it on every deploy and Terraform ignores later changes."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "max_instances" {
  description = "Hard instance ceiling. With scale to zero, this defines the cost ceiling."
  type        = number
  default     = 2

  validation {
    condition     = var.max_instances >= 1 && var.max_instances <= 5
    error_message = "To stay within the free tier the ceiling must be between 1 and 5."
  }
}

variable "keep_image_versions" {
  description = "How many images to retain in Artifact Registry. The free tier allows 0.5 GB."
  type        = number
  default     = 5
}

variable "allow_public_access" {
  description = "Allow unauthenticated invocations. Required for the Firebase Hosting rewrite to reach the service."
  type        = bool
  default     = true
}

variable "secret_accessor_ids" {
  description = "Secrets the runtime identity is allowed to read"
  type        = list(string)
  default     = []
}

variable "env" {
  description = "Non-sensitive container environment variables"
  type        = map(string)
  default     = {}
}
