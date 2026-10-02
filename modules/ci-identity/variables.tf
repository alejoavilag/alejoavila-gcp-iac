variable "project_id" {
  description = "Proyecto de GCP donde vive la federacion"
  type        = string
}

variable "pool_id" {
  description = "Identificador del Workload Identity Pool"
  type        = string
  default     = "github-pool"
}

variable "provider_id" {
  description = "Identificador del proveedor OIDC dentro del pool"
  type        = string
  default     = "github-provider"
}

variable "github_owner" {
  description = "Cuenta u organizacion de GitHub autorizada"
  type        = string
}

variable "allowed_repositories" {
  description = "Repositorios que pueden desplegar, en formato owner/repo"
  type        = list(string)

  validation {
    condition     = length(var.allowed_repositories) > 0
    error_message = "Debe autorizarse al menos un repositorio; una lista vacia dejaria la cuenta de servicio inutilizable."
  }

  validation {
    condition     = alltrue([for r in var.allowed_repositories : can(regex("^[^/]+/[^/]+$", r))])
    error_message = "Cada repositorio debe tener el formato owner/repo."
  }
}

variable "deployer_roles" {
  description = "Roles que se otorgan a la cuenta de servicio de despliegue"
  type        = list(string)
}

variable "service_account_id" {
  description = "Identificador de la cuenta de servicio de despliegue"
  type        = string
  default     = "github-deployer"
}
