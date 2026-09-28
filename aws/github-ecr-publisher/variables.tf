variable "role_name" {
  description = "Name of the GitHub Actions ECR publisher role."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the shared GitHub OIDC provider."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in owner/repository format."
  type        = string
}

variable "github_branch" {
  description = "Exact branch allowed to assume the role."
  type        = string
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