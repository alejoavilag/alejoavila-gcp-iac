variable "project_id" {
  description = "GCP project"
  type        = string
}

variable "location" {
  description = "Firestore location. Cannot be changed after the database is created."
  type        = string
}

variable "delete_protection" {
  description = "Protects the database against accidental deletion"
  type        = bool
  default     = true
}

resource "google_firestore_database" "default" {
  project     = var.project_id
  name        = "(default)"
  location_id = var.location
  type        = "FIRESTORE_NATIVE"

  concurrency_mode            = "OPTIMISTIC"
  app_engine_integration_mode = "DISABLED"

  delete_protection_state = var.delete_protection ? "DELETE_PROTECTION_ENABLED" : "DELETE_PROTECTION_DISABLED"
  deletion_policy         = "ABANDON"

  lifecycle {
    prevent_destroy = true
  }
}

output "database_name" {
  description = "Database name"
  value       = google_firestore_database.default.name
}

output "location" {
  description = "Effective Firestore location"
  value       = google_firestore_database.default.location_id
}
