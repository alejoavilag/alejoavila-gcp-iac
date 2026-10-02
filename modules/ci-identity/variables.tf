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

variable "service_accounts" {
  description = <<-EOT
    Identidades de CI. Cada entrada define una cuenta de servicio, los roles de
    proyecto que recibe, y los repositorios que pueden suplantarla.

    Separar identidades por proposito es el control central: la que despliega la
    aplicacion no puede crear infraestructura, y la que crea infraestructura no
    puede otorgar roles IAM.
  EOT

  type = map(object({
    display_name = string
    description  = optional(string, "")
    roles        = list(string)
    repositories = list(string)
  }))

  validation {
    condition = alltrue([
      for k, v in var.service_accounts : length(v.repositories) > 0
    ])
    error_message = "Cada cuenta de servicio debe autorizar al menos un repositorio; una lista vacia la deja inutilizable."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.service_accounts : [
        for r in v.repositories : can(regex("^[^/]+/[^/]+$", r))
      ]
    ]))
    error_message = "Cada repositorio debe tener el formato owner/repo."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.service_accounts : [
        for r in v.roles : !contains([
          "roles/owner",
          "roles/editor",
          "roles/resourcemanager.projectIamAdmin",
          "roles/iam.securityAdmin",
        ], r)
      ]
    ]))
    error_message = "Ninguna identidad de CI puede recibir owner, editor ni permisos para otorgar IAM: con ellos podria escalarse a propietario del proyecto."
  }
}
