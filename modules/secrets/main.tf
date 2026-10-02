variable "project_id" {
  description = "GCP project"
  type        = string
}

variable "secret_ids" {
  description = "Secret identifiers to create. Containers only: values are loaded outside Terraform."
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
  description = "Identifiers of the created secrets"
  value       = [for s in google_secret_manager_secret.this : s.secret_id]
}
