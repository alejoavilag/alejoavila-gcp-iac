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

variable "github_owner" {
  description = "Cuenta de GitHub autorizada a desplegar"
  type        = string
}

variable "allowed_repositories" {
  description = "Repositorios autorizados a suplantar la cuenta de despliegue"
  type        = list(string)
}

variable "max_instances" {
  description = "Tope duro de instancias de Cloud Run"
  type        = number
  default     = 2
}
