output "workload_identity_provider" {
  description = "Value for workload_identity_provider in google-github-actions/auth. Not a secret: security comes from the OIDC binding."
  value       = module.ci_identity.workload_identity_provider
}

output "deployer_service_account" {
  description = "Identity that deploys the application"
  value       = module.ci_identity.service_account_emails["github-deployer"]
}

output "terraform_admin_service_account" {
  description = "Identity that applies envs/prod from the infrastructure repository"
  value       = module.ci_identity.service_account_emails["terraform-admin"]
}

output "api_runtime_service_account" {
  description = "Value for runtime_service_account_email in envs/prod"
  value       = google_service_account.api_runtime.email
}

output "hosting_site_id" {
  description = "Firebase Hosting site the shell deploys to"
  value       = google_firebase_hosting_site.portfolio.site_id
}

output "hosting_default_url" {
  description = "Default site URL, before attaching a custom domain"
  value       = google_firebase_hosting_site.portfolio.default_url
}
