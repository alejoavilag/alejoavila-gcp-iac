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
