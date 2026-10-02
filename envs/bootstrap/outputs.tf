output "workload_identity_provider" {
  description = "Valor para workload_identity_provider en google-github-actions/auth. No es secreto: la seguridad viene del vinculo OIDC."
  value       = module.ci_identity.workload_identity_provider
}

output "deployer_service_account" {
  description = "Identidad que despliega la aplicacion"
  value       = module.ci_identity.service_account_emails["github-deployer"]
}

output "terraform_admin_service_account" {
  description = "Identidad que aplica envs/prod desde el repositorio de infraestructura"
  value       = module.ci_identity.service_account_emails["terraform-admin"]
}

output "api_runtime_service_account" {
  description = "Valor para runtime_service_account_email en envs/prod"
  value       = google_service_account.api_runtime.email
}

output "hosting_site_id" {
  description = "Sitio de Firebase Hosting al que despliega el shell"
  value       = google_firebase_hosting_site.portfolio.site_id
}

output "hosting_default_url" {
  description = "URL por defecto del sitio, antes de conectar el dominio propio"
  value       = google_firebase_hosting_site.portfolio.default_url
}
