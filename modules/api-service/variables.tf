variable "project_id" {
  description = "Proyecto de GCP"
  type        = string
}

variable "region" {
  description = "Region de Cloud Run y Artifact Registry"
  type        = string
}

variable "service_name" {
  description = "Nombre del servicio de Cloud Run"
  type        = string
}

variable "repository_id" {
  description = "Nombre del repositorio de Artifact Registry"
  type        = string
}

variable "image" {
  description = "Imagen inicial. CI la reemplaza en cada despliegue, por eso Terraform ignora sus cambios posteriores."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "max_instances" {
  description = "Tope duro de instancias. Es el control de gasto: con escalado a cero, define el techo de costo."
  type        = number
  default     = 2

  validation {
    condition     = var.max_instances >= 1 && var.max_instances <= 5
    error_message = "Para mantenerse dentro de la capa gratuita el tope debe estar entre 1 y 5."
  }
}

variable "keep_image_versions" {
  description = "Cuantas imagenes conservar en Artifact Registry. La capa gratuita da 0,5 GB."
  type        = number
  default     = 5
}

variable "allow_public_access" {
  description = "Permite invocaciones sin autenticar. Necesario para que el rewrite de Firebase Hosting alcance el servicio."
  type        = bool
  default     = true
}

variable "secret_accessor_ids" {
  description = "Secretos de Secret Manager que la cuenta de ejecucion puede leer"
  type        = list(string)
  default     = []
}

variable "env" {
  description = "Variables de entorno no sensibles del contenedor"
  type        = map(string)
  default     = {}
}
