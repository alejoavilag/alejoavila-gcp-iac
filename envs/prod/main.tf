// Capa de aplicacion.
//
// La aplica CI con la identidad terraform-admin, que administra recursos pero
// no puede otorgar roles IAM ni crear cuentas de servicio. Todo lo que implique
// escalar privilegios vive en envs/bootstrap.

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

  runtime_service_account_email = var.runtime_service_account_email
  secret_accessor_ids           = module.secrets.secret_ids

  env = {
    NODE_ENV    = "production"
    GCP_PROJECT = var.project_id
  }
}
