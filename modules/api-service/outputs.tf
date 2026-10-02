output "service_url" {
  description = "URL publica del servicio de Cloud Run"
  value       = google_cloud_run_v2_service.api.uri
}

output "service_name" {
  description = "Nombre del servicio, para el rewrite de Firebase Hosting"
  value       = google_cloud_run_v2_service.api.name
}

output "runtime_service_account" {
  description = "Cuenta de servicio con la que corre el contenedor"
  value       = google_service_account.runtime.email
}

output "repository_url" {
  description = "Host y ruta del repositorio de imagenes, para docker push"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.api.repository_id}"
}
