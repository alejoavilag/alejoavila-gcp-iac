variable "project_id" {
  description = "Proyecto de GCP"
  type        = string
}

variable "region" {
  description = "Region principal"
  type        = string
  default     = "us-east1"
}

variable "github_owner" {
  description = "Cuenta de GitHub autorizada"
  type        = string
}

variable "tfstate_bucket" {
  description = "Bucket del estado de Terraform. Creado en el bootstrap manual, fuera de este codigo."
  type        = string
}

variable "api_service_name" {
  description = "Nombre del servicio de Cloud Run, usado para derivar el nombre de su cuenta de ejecucion"
  type        = string
  default     = "alejoavila-api"
}

variable "hosting_site_id" {
  description = "Identificador del sitio de Firebase Hosting. Define el subdominio <site_id>.web.app y es unico a nivel global, no solo dentro del proyecto."
  type        = string
  default     = "alejoavila"

  validation {
    condition     = var.hosting_site_id != "alejoavila-web"
    error_message = "No usar el id del proyecto: Firebase ya crea un sitio por defecto con ese nombre y el apply chocaria."
  }

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$", var.hosting_site_id))
    error_message = "Debe tener entre 3 y 30 caracteres, solo minusculas, numeros y guiones, sin empezar ni terminar en guion."
  }
}
