variable "cluster_name" {
  type        = string
  description = "EKS cluster for the caller-generated Helm provider."
}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "account_id must contain exactly twelve digits."
  }
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "role_name" {
  type = string
}

variable "namespace" {
  type    = string
  default = "backend-dev"
  validation {
    condition     = var.namespace == "backend-dev"
    error_message = "This module is restricted to the pre-existing backend-dev namespace."
  }
}