variable "project_id" {
  description = "Proyecto de GCP"
  type        = string
}

variable "location" {
  description = "Ubicacion de Firestore. NO se puede cambiar despues de crear la base."
  type        = string
}

variable "delete_protection" {
  description = "Protege la base contra borrado accidental"
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

  # ABANDON deja la base intacta si se elimina del estado de Terraform. La
  # ubicacion es permanente y los datos de analitica no son reconstruibles.
  deletion_policy = "ABANDON"

  lifecycle {
    prevent_destroy = true
  }
}

output "database_name" {
  description = "Nombre de la base de datos"
  value       = google_firestore_database.default.name
}

output "location" {
  description = "Ubicacion efectiva de Firestore"
  value       = google_firestore_database.default.location_id
}
