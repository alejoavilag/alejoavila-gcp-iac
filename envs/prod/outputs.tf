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

output "workload_identity_provider" {
  description = "Valor para workload_identity_provider en google-github-actions/auth"
  value       = module.ci_identity.workload_identity_provider
}

output "deployer_service_account" {
  description = "Valor para service_account en google-github-actions/auth"
  value       = module.ci_identity.service_account_email
}

output "runtime_service_account" {
  description = "Identidad con la que corre el contenedor"
  value       = module.api.runtime_service_account
}
