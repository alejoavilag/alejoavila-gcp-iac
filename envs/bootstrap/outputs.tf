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

output "custom_domain" {
  description = "Apex domain attached to the Hosting site, empty when none is configured"
  value       = var.custom_domain
}

output "custom_domain_dns_records" {
  description = "Records to create at the registrar. Read desired[].records: every entry needs its type and rdata copied verbatim."
  value = {
    apex = try(google_firebase_hosting_custom_domain.apex[0].required_dns_updates, [])
    www  = try(google_firebase_hosting_custom_domain.www[0].required_dns_updates, [])
  }
}

output "custom_domain_status" {
  description = "Verification and serving state of the custom domain, refreshed on every plan"
  value = {
    apex = try({
      host      = google_firebase_hosting_custom_domain.apex[0].host_state
      ownership = google_firebase_hosting_custom_domain.apex[0].ownership_state
      issues    = google_firebase_hosting_custom_domain.apex[0].issues
    }, null)
    www = try({
      host      = google_firebase_hosting_custom_domain.www[0].host_state
      ownership = google_firebase_hosting_custom_domain.www[0].ownership_state
      issues    = google_firebase_hosting_custom_domain.www[0].issues
    }, null)
  }
}

output "widgets_site_id" {
  description = "Firebase Hosting site the widget deploys to"
  value       = google_firebase_hosting_site.widgets.site_id
}

output "widgets_default_url" {
  description = "Default widgets site URL, usable before the subdomain resolves"
  value       = google_firebase_hosting_site.widgets.default_url
}

output "widgets_domain" {
  description = "Subdomain that serves the widgets, empty when no custom domain is configured"
  value       = try(google_firebase_hosting_custom_domain.widgets[0].custom_domain, "")
}

output "widgets_domain_dns_records" {
  description = "Records to create at the registrar for the widgets subdomain"
  value       = try(google_firebase_hosting_custom_domain.widgets[0].required_dns_updates, [])
}

output "widgets_domain_status" {
  description = "Verification and serving state of the widgets subdomain"
  value = try({
    host      = google_firebase_hosting_custom_domain.widgets[0].host_state
    ownership = google_firebase_hosting_custom_domain.widgets[0].ownership_state
    issues    = google_firebase_hosting_custom_domain.widgets[0].issues
  }, null)
}
