variable "project_id" {
  description = "Proyecto de GCP"
  type        = string
}

variable "secret_ids" {
  description = "Identificadores de los secretos a crear"
  type        = list(string)
}

# Terraform crea unicamente el contenedor del secreto, nunca su contenido.
#
# Un google_secret_manager_secret_version guardaria el valor en texto plano
# dentro del estado de Terraform, que vive en un bucket de GCS. El estado no es
# un lugar seguro para credenciales. Los valores se cargan aparte con:
#
#   echo -n "VALOR" | gcloud secrets versions add NOMBRE --data-file=-
#
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
