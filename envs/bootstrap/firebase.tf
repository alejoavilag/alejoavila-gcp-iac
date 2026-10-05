resource "google_firebase_project" "default" {
  provider = google-beta
  project  = var.project_id

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_firebase_hosting_site" "portfolio" {
  provider = google-beta
  project  = var.project_id
  site_id  = var.hosting_site_id

  depends_on = [google_firebase_project.default]
}

resource "google_firebase_hosting_custom_domain" "apex" {
  count = var.custom_domain == "" ? 0 : 1

  provider              = google-beta
  project               = var.project_id
  site_id               = google_firebase_hosting_site.portfolio.site_id
  custom_domain         = var.custom_domain
  cert_preference       = "GROUPED"
  wait_dns_verification = false
}

resource "google_firebase_hosting_custom_domain" "www" {
  count = var.custom_domain == "" ? 0 : 1

  provider              = google-beta
  project               = var.project_id
  site_id               = google_firebase_hosting_site.portfolio.site_id
  custom_domain         = "www.${var.custom_domain}"
  redirect_target       = var.custom_domain
  wait_dns_verification = false
}
