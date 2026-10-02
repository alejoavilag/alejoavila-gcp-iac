variable "project_id" {
  description = "Proyecto de GCP"
  type        = string
}

variable "region" {
  description = "Region principal. us-east1 es Tier 1, elegible para capa gratuita, y la de menor latencia a Colombia entre las Tier 1."
  type        = string
  default     = "us-east1"
}

variable "firestore_location" {
  description = "Ubicacion de Firestore. Permanente una vez creada la base."
  type        = string
  default     = "us-east1"
}

variable "runtime_service_account_email" {
  description = "Cuenta de ejecucion del contenedor. Sale de la salida api_runtime_service_account de envs/bootstrap."
  type        = string
}

variable "max_instances" {
  description = "Tope duro de instancias de Cloud Run"
  type        = number
  default     = 2
}
