variable "cloudflare_zone_id" {
  description = "Cloudflare zone containing the frontend domain"
  type        = string
}

variable "frontend_domain_name" {
  description = "Frontend hostname covered by the CloudFront certificate"
  type        = string
}

variable "distribution_domain_name" {
  description = "CloudFront distribution hostname, without scheme or path"
  type        = string

  validation {
    condition = can(regex(
      "^[a-z0-9-]+\\.cloudfront\\.net$",
      var.distribution_domain_name
    ))
    error_message = "Provide a CloudFront hostname without scheme or path."
  }
}