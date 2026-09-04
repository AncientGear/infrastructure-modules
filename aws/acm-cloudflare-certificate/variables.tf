variable "domain_name" {
  type        = string
  description = "The domain name for the ACM certificate"
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "Additional domain names for the certificate"
  default     = []
}

variable "cloudflare_zone_id" {
  type        = string
  description = "The Cloudflare zone ID"
}

variable "tags" {
  type        = map(string)
  description = "Tags for the ACM certificate"
  default     = {}
}
