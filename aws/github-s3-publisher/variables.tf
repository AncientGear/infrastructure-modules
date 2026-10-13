variable "role_name" {
  description = "Name of the GitHub Actions S3 publisher role."
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

variable "bucket_arn" {
  description = "ARN of the destination S3 bucket."
  type        = string
}

variable "tags" {
  description = "Tags assigned to the IAM role."
  type        = map(string)
  default     = {}
}

variable "enable_promotion" {
  description = "Enable release promotion to current and CloudFront invalidation."
  type        = bool
  default     = false
}

variable "cloudfront_distribution_arn" {
  description = "Exact CloudFront distribution ARN allowed for invalidation."
  type        = string
  default     = null

  validation {
    condition = (
      !var.enable_promotion ||
      can(regex(
        "^arn:aws:cloudfront::[0-9]{12}:distribution/[A-Z0-9]+$",
        var.cloudfront_distribution_arn
      ))
    )
    error_message = "Promotion requires an exact CloudFront distribution ARN."
  }
}