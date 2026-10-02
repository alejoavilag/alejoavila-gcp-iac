variable "project_id" {
  description = "Proyecto de GCP"
  type        = string
}

variable "secret_ids" {
  description = "Identificadores de los secretos a crear. Solo el contenedor: los valores se cargan fuera de Terraform."
  type        = list(string)
}

resource "google_secret_manager_secret" "this" {
  for_each = toset(var.secret_ids)

  project   = var.project_id
  secret_id = each.value

  replication {
    auto {}
  }

  lifecycle {
    prevent_destroy = true
  }
}

output "secret_ids" {
  description = "Identificadores de los secretos creados"
  value       = [for s in google_secret_manager_secret.this : s.secret_id]
}
