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
  description = "Identificador del sitio de Firebase Hosting. Unico a nivel global y distinto del sitio por defecto que Firebase crea con el id del proyecto."
  type        = string
  default     = "alejoavila-portfolio"

  validation {
    condition     = var.hosting_site_id != "alejoavila-web"
    error_message = "No usar el id del proyecto: Firebase ya crea un sitio por defecto con ese nombre y el apply chocaria."
  }
}
