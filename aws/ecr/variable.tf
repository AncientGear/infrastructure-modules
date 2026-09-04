variable "name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The image tag mutability setting for the ECR repository"
  type        = string
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "Whether to enable image scanning on push for the ECR repository"
  type        = bool
  default     = true
}

variable "tags" {
  description = "The tags to assign to the ECR repository"
  type        = map(string)
}