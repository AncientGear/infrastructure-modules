variable "cluster_name" {
  description = "EKS cluster used by the caller-generated Helm provider."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.cluster_name)) > 0
    error_message = "cluster_name must not be empty."
  }
}

variable "region" {
  description = "AWS region used by the caller-generated AWS provider."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "region must not be empty."
  }
}