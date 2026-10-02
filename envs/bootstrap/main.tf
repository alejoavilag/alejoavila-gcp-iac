// Capa de bootstrap.
//
// Concentra todo lo que puede escalar privilegios: identidades, roles de
// proyecto y la federacion. Se aplica a mano, con credenciales de usuario, y
// cambia muy pocas veces.
//
// La capa envs/prod la aplica CI usando la identidad que se crea aqui. Ese
// reparto es el que impide que un commit malicioso en cualquier repositorio
// termine otorgandose permisos de propietario.

# Identidad con la que corre el contenedor en Cloud Run. Vive aqui, y no en el
# modulo del API, porque crearla y darle roles de proyecto exige permisos de
# administracion de IAM que CI no debe tener.
resource "google_service_account" "api_runtime" {
  project      = var.project_id
  account_id   = "${var.api_service_name}-runtime"
  display_name = "Ejecucion de ${var.api_service_name}"
  description  = "Identidad del contenedor en Cloud Run. Permiso minimo."
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
    # Despliega la aplicacion. No puede crear ni modificar infraestructura.
    github-deployer = {
      display_name = "Despliegue de aplicacion"
      description  = "Publica el shell en Hosting y revisiones en Cloud Run. Sin permisos de infraestructura."
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

    # Aplica la capa envs/prod. Administra recursos, pero NO puede otorgar roles
    # IAM ni crear cuentas de servicio, asi que no puede escalar a propietario.
    terraform-admin = {
      display_name = "Terraform de la capa de aplicacion"
      description  = "Aplica envs/prod. Solo desde el repositorio de infraestructura."
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

# Acceso al estado de Terraform acotado al bucket, no a todo Storage del
# proyecto.
resource "google_storage_bucket_iam_member" "terraform_admin_state" {
  bucket = var.tfstate_bucket
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.ci_identity.service_account_emails["terraform-admin"]}"
}
