variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster is deployed"
  type        = string
}

variable "aws_region" {
  description = "The AWS region where the EKS cluster is deployed"
  type        = string
}

variable "account_id" {
  description = "The AWS account ID where the EKS cluster is deployed"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "oidc_provider_url" {
  description = "The URL of the OIDC provider for the EKS cluster"
  type        = string

  validation {
    condition = can(regex(
      "^https://oidc\\.eks\\.([a-z0-9-]+)\\.amazonaws\\.com/id/([A-Za-z0-9]+)$",
      var.oidc_provider_url
    ))

    error_message = "The oidc_provider_url must be a valid EKS OIDC provider URL."
  }
}

variable "namespace" {
  description = "The namespace where the AWS Load Balancer Controller will be deployed"
  type        = string
  default     = "kube-system"
}

variable "service_account_name" {
  description = "The name of the service account for the AWS Load Balancer Controller"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "role_name" {
  description = "The name of the IAM role for the AWS Load Balancer Controller"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the IAM role"
  type        = map(string)
  default     = {}
}

variable "aws_load_balancer_controller_policy_name" {
  description = "The name of the IAM policy for the AWS Load Balancer Controller"
  type        = string
  default     = "AWSLoadBalancerControllerIAMPolicy"
}
