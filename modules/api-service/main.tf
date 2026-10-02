resource "google_artifact_registry_repository" "api" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_id
  format        = "DOCKER"
  description   = "Imagenes del API del portafolio"

  # La capa gratuita da 0,5 GB. Sin limpieza, el historial de imagenes la agota.
  cleanup_policies {
    id     = "conservar-recientes"
    action = "KEEP"
    most_recent_versions {
      keep_count = var.keep_image_versions
    }
  }

  cleanup_policies {
    id     = "borrar-el-resto"
    action = "DELETE"
    condition {
      older_than = "2592000s"
    }
  }
}

resource "google_service_account" "runtime" {
  project      = var.project_id
  account_id   = "${var.service_name}-runtime"
  display_name = "Ejecucion de ${var.service_name}"
  description  = "Identidad del contenedor en Cloud Run. Permiso minimo, nunca la SA por defecto de Compute."
}

resource "google_project_iam_member" "runtime_firestore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.runtime.email}"
}

resource "google_secret_manager_secret_iam_member" "runtime" {
  for_each = toset(var.secret_accessor_ids)

  project   = var.project_id
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.runtime.email}"
}

resource "google_cloud_run_v2_service" "api" {
  project             = var.project_id
  name                = var.service_name
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

  template {
    service_account                  = google_service_account.runtime.email
    max_instance_request_concurrency = 80
    timeout                          = "30s"

    scaling {
      min_instance_count = 0
      max_instance_count = var.max_instances
    }

    containers {
      image = var.image

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
        # Sin CPU fuera de peticion no se factura tiempo ocioso; es lo que hace
        # viable el escalado a cero dentro de la capa gratuita.
        cpu_idle          = true
        startup_cpu_boost = true
      }

      dynamic "env" {
        for_each = var.env
        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }

  # CI publica la imagen nueva en cada despliegue. Sin esto, Terraform la
  # revertiria a la inicial en el siguiente apply.
  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      client,
      client_version,
    ]
  }
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  count = var.allow_public_access ? 1 : 0

  project  = var.project_id
  location = google_cloud_run_v2_service.api.location
  name     = google_cloud_run_v2_service.api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
