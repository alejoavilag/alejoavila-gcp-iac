variable "project_id" {
  description = "GCP project that hosts the federation"
  type        = string
}

variable "pool_id" {
  description = "Workload Identity Pool identifier"
  type        = string
  default     = "github-pool"
}

variable "provider_id" {
  description = "OIDC provider identifier inside the pool"
  type        = string
  default     = "github-provider"
}

variable "github_owner" {
  description = "GitHub account or organization allowed to authenticate"
  type        = string
}

variable "service_accounts" {
  description = "CI identities. Each entry defines a service account, its project roles, and the repositories allowed to impersonate it."

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
    error_message = "Every service account must authorize at least one repository; an empty list makes it unusable."
  }

  validation {
    condition = alltrue(flatten([
      for k, v in var.service_accounts : [
        for r in v.repositories : can(regex("^[^/]+/[^/]+$", r))
      ]
    ]))
    error_message = "Each repository must use the owner/repo format."
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
    error_message = "CI identities must not be granted owner, editor, or IAM-granting roles: any of them allows self-escalation to project owner."
  }
}
