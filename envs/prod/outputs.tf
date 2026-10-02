output "api_url" {
  description = "Cloud Run URL. The Firebase Hosting rewrite points here."
  value       = module.api.service_url
}

output "api_service_name" {
  description = "Service name for the Firebase Hosting rewrite"
  value       = module.api.service_name
}

output "artifact_repository" {
  description = "docker push target"
  value       = module.api.repository_url
}
