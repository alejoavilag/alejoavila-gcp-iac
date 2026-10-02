output "api_url" {
  description = "URL de Cloud Run. El rewrite de Firebase Hosting apunta aqui."
  value       = module.api.service_url
}

output "api_service_name" {
  description = "Nombre del servicio para el rewrite de Firebase Hosting"
  value       = module.api.service_name
}

output "artifact_repository" {
  description = "Destino de docker push"
  value       = module.api.repository_url
}
