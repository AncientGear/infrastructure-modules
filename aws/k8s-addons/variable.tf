variable "cluster_name" {
  description = "Name of the EKS cluster where addons are installed."
  type        = string

  validation {
    condition     = length(trimspace(var.cluster_name)) > 0
    error_message = "cluster_name must not be empty."
  }
}

variable "region" {
  description = "AWS region where the EKS cluster is deployed."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}(-[a-z]+)+-[0-9]+$", var.region))
    error_message = "region must be a valid AWS region identifier, such as us-east-1."
  }
}

variable "vpc_id" {
  description = "ID of the VPC containing the EKS cluster."
  type        = string

  validation {
    condition     = can(regex("^vpc-[0-9a-f]+$", var.vpc_id))
    error_message = "vpc_id must be a valid VPC ID, such as vpc-0123456789abcdef0."
  }
}

variable "aws_load_balancer_controller" {
  description = "Configuration for the AWS Load Balancer Controller addon. The role ARN is required only when enabled."

  type = object({
    enabled              = bool
    role_arn             = optional(string)
    namespace            = optional(string, "kube-system")
    service_account_name = optional(string, "aws-load-balancer-controller")
  })

  default = {
    enabled = false
  }

  validation {
    condition = (
      !var.aws_load_balancer_controller.enabled ||
      (
        try(trimspace(var.aws_load_balancer_controller.role_arn), "") != "" &&
        can(regex("^arn:[^:]+:iam::[0-9]{12}:role/.+$", var.aws_load_balancer_controller.role_arn))
      )
    )
    error_message = "aws_load_balancer_controller.role_arn must be a valid IAM role ARN when the addon is enabled."
  }

  validation {
    condition = (
      length(trimspace(var.aws_load_balancer_controller.namespace)) > 0 &&
      length(trimspace(var.aws_load_balancer_controller.service_account_name)) > 0
    )
    error_message = "aws_load_balancer_controller.namespace and service_account_name must not be empty."
  }
}
