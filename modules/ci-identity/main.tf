locals {
  # Producto cartesiano de cuenta x repositorio, para crear un binding por par.
  sa_repo_pairs = merge([
    for sa_key, sa in var.service_accounts : {
      for repo in sa.repositories :
      "${sa_key}|${repo}" => { sa_key = sa_key, repo = repo }
    }
  ]...)

  sa_role_pairs = merge([
    for sa_key, sa in var.service_accounts : {
      for role in sa.roles :
      "${sa_key}|${role}" => { sa_key = sa_key, role = role }
    }
  ]...)
}

resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = "GitHub Actions"
  description               = "Federacion de identidad para CI sin llaves de larga vida"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = "GitHub OIDC"

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
    "attribute.ref"              = "assertion.ref"
  }

  # Primer filtro. Sin esta condicion, el flujo OIDC de CUALQUIER repositorio de
  # GitHub en el mundo podria pedir credenciales de este proyecto.
  attribute_condition = "assertion.repository_owner == '${var.github_owner}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "ci" {
  for_each = var.service_accounts

  project      = var.project_id
  account_id   = each.key
  display_name = each.value.display_name
  description  = each.value.description
}

# Segundo filtro, el que de verdad acota: solo los repositorios listados para
# cada cuenta pueden suplantarla. Google lo verifica, no GitHub.
resource "google_service_account_iam_member" "workload_identity_user" {
  for_each = local.sa_repo_pairs

  service_account_id = google_service_account.ci[each.value.sa_key].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${each.value.repo}"
}

resource "google_project_iam_member" "ci" {
  for_each = local.sa_role_pairs

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.ci[each.value.sa_key].email}"
}
