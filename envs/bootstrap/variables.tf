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
