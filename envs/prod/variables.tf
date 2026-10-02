variable "project_id" {
  description = "GCP project"
  type        = string
}

variable "region" {
  description = "Primary region. us-east1 is Tier 1, free-tier eligible, and the lowest-latency Tier 1 region for Colombia."
  type        = string
  default     = "us-east1"
}

variable "firestore_location" {
  description = "Firestore location. Permanent once the database is created."
  type        = string
  default     = "us-east1"
}

variable "runtime_service_account_email" {
  description = "Container runtime identity. Comes from the api_runtime_service_account output of envs/bootstrap."
  type        = string
}

variable "max_instances" {
  description = "Hard instance ceiling for Cloud Run"
  type        = number
  default     = 2
}
