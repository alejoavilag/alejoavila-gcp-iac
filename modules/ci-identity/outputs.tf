output "workload_identity_provider" {
  description = "Nombre completo del proveedor, para google-github-actions/auth"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "service_account_emails" {
  description = "Correo de cada identidad de CI, por clave"
  value       = { for k, sa in google_service_account.ci : k => sa.email }
}

output "pool_name" {
  description = "Nombre completo del Workload Identity Pool"
  value       = google_iam_workload_identity_pool.github.name
}
