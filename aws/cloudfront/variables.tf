variable "alb_origin_domain_name" {
  description = "Custom DNS hostname used by CloudFront to reach the ALB"
  type        = string
}

variable "cloudfront_origin_access_control_id" {
  type = string
}

variable "bucket_arn" {
  type = string
}

variable "bucket_id" {
  type = string
}

variable "bucket_regional_domain_name" {
  type = string
}
variable "acm_certificate_arn" {
  type = string
}
variable "aliases" {
  type = list(string)
}
variable "price_class" {
  type    = string
  default = "PriceClass_100"
}
variable "tags" {
  type    = map(string)
  default = {}
}

variable "function_name" {
  type    = string
  default = "spa_rewrite"
}

variable "alb_origin_arn" {
  description = "ARN of the existing internal ALB managed by Kubernetes"
  type        = string
}

variable "vpc_origin_name" {
  description = "Name of the CloudFront VPC origin"
  type        = string
}

variable "frontend_release_id" {
  description = "Published S3 release identifier: GitHub run ID and attempt"
  type        = string

  validation {
    condition     = can(regex("^[0-9]+-[0-9]+$", var.frontend_release_id))
    error_message = "Use the published release identifier in run_id-run_attempt format."
  }
}

variable "frontend_origin_mode" {
  description = "S3 origin selection: immutable release or stable current prefix."
  type        = string
  default     = "release"

  validation {
    condition     = contains(["release", "current"], var.frontend_origin_mode)
    error_message = "frontend_origin_mode must be release or current."
  }
}