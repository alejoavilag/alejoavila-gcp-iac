locals {
  secret_ids = [
    "gemini-api-key",
    "recaptcha-secret",
    "smtp-password",
  ]
}

module "secrets" {
  source = "../../modules/secrets"

  project_id = var.project_id
  secret_ids = local.secret_ids
}

module "datastore" {
  source = "../../modules/datastore"

  project_id = var.project_id
  location   = var.firestore_location
}

module "api" {
  source = "../../modules/api-service"

  project_id    = var.project_id
  region        = var.region
  service_name  = "alejoavila-api"
  repository_id = "alejoavila-api"
  max_instances = var.max_instances

  secret_accessor_ids = module.secrets.secret_ids

  env = {
    NODE_ENV    = "production"
    GCP_PROJECT = var.project_id
  }
}

module "ci_identity" {
  source = "../../modules/ci-identity"

  project_id           = var.project_id
  github_owner         = var.github_owner
  allowed_repositories = var.allowed_repositories

  deployer_roles = [
    "roles/run.admin",               # desplegar revisiones de Cloud Run
    "roles/artifactregistry.writer", # publicar imagenes
    "roles/iam.serviceAccountUser",  # actuar como la SA de ejecucion
    "roles/firebasehosting.admin",   # publicar el sitio estatico
  ]
}
