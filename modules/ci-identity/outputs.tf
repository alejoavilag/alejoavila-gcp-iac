output "workload_identity_provider" {
  description = "Full provider name, for google-github-actions/auth"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "service_account_emails" {
  description = "Email of each CI identity, keyed by account id"
  value       = { for k, sa in google_service_account.ci : k => sa.email }
}

output "pool_name" {
  description = "Full Workload Identity Pool name"
  value       = google_iam_workload_identity_pool.github.name
}
