variable "role_name" {
  description = "Name of the GitHub Actions ECR publisher role."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the shared GitHub OIDC provider."
  type        = string
}

variable "github_subject" {
  description = "Exact GitHub OIDC subject allowed to assume the role."
  type        = string

  validation {
    condition = (
      startswith(var.github_subject, "repo:") &&
      !strcontains(var.github_subject, "*") &&
      !strcontains(var.github_subject, "?")
    )
    error_message = "Provide an exact repository subject without wildcards."
  }
}

variable "tags" {
  description = "Tags assigned to the IAM role."
  type        = map(string)
  default     = {}
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository where images may be published."
  type        = string
}