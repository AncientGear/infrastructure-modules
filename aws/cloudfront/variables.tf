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