output "workload_identity_provider" {
  description = "Nombre completo del proveedor, para el campo workload_identity_provider de google-github-actions/auth"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "service_account_email" {
  description = "Cuenta de servicio que GitHub Actions suplanta"
  value       = google_service_account.deployer.email
}

output "pool_name" {
  description = "Nombre completo del Workload Identity Pool"
  value       = google_iam_workload_identity_pool.github.name
}
