output "service_url" {
  description = "Public Cloud Run service URL"
  value       = google_cloud_run_v2_service.api.uri
}

output "service_name" {
  description = "Service name, for the Firebase Hosting rewrite"
  value       = google_cloud_run_v2_service.api.name
}

output "repository_url" {
  description = "Image repository host and path, for docker push"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.api.repository_id}"
}
