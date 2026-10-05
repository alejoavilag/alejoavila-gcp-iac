variable "project_id" {
  description = "GCP project"
  type        = string
}

variable "region" {
  description = "Primary region"
  type        = string
  default     = "us-east1"
}

variable "github_owner" {
  description = "GitHub account allowed to authenticate"
  type        = string
}

variable "tfstate_bucket" {
  description = "Terraform state bucket. Created during manual bootstrap, outside this code."
  type        = string
}

variable "api_service_name" {
  description = "Cloud Run service name, used to derive its runtime service account name"
  type        = string
  default     = "alejoavila-api"
}

variable "hosting_site_id" {
  description = "Firebase Hosting site identifier. Defines the <site_id>.web.app subdomain and is globally unique, not just within the project."
  type        = string
  default     = "alejoavila"

  validation {
    condition     = var.hosting_site_id != "alejoavila-web"
    error_message = "Do not reuse the project id: Firebase already creates a default site with that name and the apply would collide."
  }

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$", var.hosting_site_id))
    error_message = "Must be 3 to 30 characters, lowercase letters, digits and hyphens only, not starting or ending with a hyphen."
  }
}

variable "custom_domain" {
  description = "Apex domain to attach to the Hosting site, without protocol or www subdomain. Empty leaves the site on its default URL."
  type        = string
  default     = ""

  validation {
    condition     = var.custom_domain == "" || can(regex("^[a-z0-9][a-z0-9-]*(\\.[a-z0-9][a-z0-9-]*)+$", var.custom_domain))
    error_message = "Use a bare domain such as example.com, with no protocol, port or path."
  }

  validation {
    condition     = !startswith(var.custom_domain, "www.")
    error_message = "Set the apex domain: the www subdomain is attached automatically as a redirect to it."
  }
}

variable "widgets_site_id" {
  description = "Firebase Hosting site that serves the runtime widgets, kept separate because a deploy replaces a whole site."
  type        = string
  default     = "alejoavila-widgets"

  validation {
    condition     = var.widgets_site_id != var.hosting_site_id
    error_message = "The widgets site must differ from the shell site: sharing one would make each deploy erase the other."
  }

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$", var.widgets_site_id))
    error_message = "Must be 3 to 30 characters, lowercase letters, digits and hyphens only, not starting or ending with a hyphen."
  }
}

variable "widgets_subdomain" {
  description = "Label prefixed to the apex domain for the widgets site, attached with a CNAME."
  type        = string
  default     = "widgets"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$", var.widgets_subdomain))
    error_message = "Must be a single DNS label: lowercase letters, digits and hyphens, not starting or ending with a hyphen."
  }
}
