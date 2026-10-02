resource "google_service_account" "api_runtime" {
  project      = var.project_id
  account_id   = "${var.api_service_name}-runtime"
  display_name = "Runtime for ${var.api_service_name}"
  description  = "Cloud Run container identity. Least privilege."
}

resource "google_project_iam_member" "api_runtime_firestore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.api_runtime.email}"
}

module "ci_identity" {
  source = "../../modules/ci-identity"

  project_id   = var.project_id
  github_owner = var.github_owner

  service_accounts = {
    github-deployer = {
      display_name = "Application deployment"
      description  = "Publishes the shell to Hosting and revisions to Cloud Run. No infrastructure permissions."
      roles = [
        "roles/run.admin",
        "roles/artifactregistry.writer",
        "roles/iam.serviceAccountUser",
        "roles/firebasehosting.admin",
      ]
      repositories = [
        "alejoavilag/shell-alejoavila-web-ui",
        "alejoavilag/alejoavila-chat-wc-lib-web-ui",
        "alejoavilag/alejoavila-api-mngr",
      ]
    }

    terraform-admin = {
      display_name = "Application layer Terraform"
      description  = "Applies envs/prod. Only from the infrastructure repository."
      roles = [
        "roles/run.admin",
        "roles/artifactregistry.admin",
        "roles/datastore.owner",
        "roles/secretmanager.admin",
        "roles/iam.serviceAccountUser",
      ]
      repositories = [
        "alejoavilag/alejoavila-gcp-iac",
      ]
    }
  }
}

resource "google_storage_bucket_iam_member" "terraform_admin_state" {
  bucket = var.tfstate_bucket
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.ci_identity.service_account_emails["terraform-admin"]}"
}
