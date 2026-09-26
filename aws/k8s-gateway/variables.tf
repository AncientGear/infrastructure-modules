variable "platform_namespace" {
  description = "Existing namespace containing the shared platform Gateway and its LoadBalancerConfiguration; owned outside this module."
  type        = string
  default     = "gateway-system"

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.platform_namespace)) && length(var.platform_namespace) <= 63
    error_message = "platform_namespace must be a Kubernetes DNS label of at most 63 lowercase letters, numbers, or hyphens."
  }
}

variable "gateway_class_name" {
  description = "Cluster-scoped GatewayClass name managed by this module."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.gateway_class_name)) && length(var.gateway_class_name) <= 63
    error_message = "gateway_class_name must be a Kubernetes DNS label of at most 63 lowercase letters, numbers, or hyphens."
  }
}

variable "gateway_name" {
  description = "Name of the internal HTTPS Gateway."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.gateway_name)) && length(var.gateway_name) <= 63
    error_message = "gateway_name must be a Kubernetes DNS label of at most 63 lowercase letters, numbers, or hyphens."
  }
}

variable "load_balancer_configuration_name" {
  description = "Name of the AWS LoadBalancerConfiguration referenced by the Gateway."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.load_balancer_configuration_name)) && length(var.load_balancer_configuration_name) <= 63
    error_message = "load_balancer_configuration_name must be a Kubernetes DNS label of at most 63 lowercase letters, numbers, or hyphens."
  }
}

variable "hostname" {
  description = "DNS hostname presented by the Gateway HTTPS listener. Wildcard hostnames may begin with '*.'."
  type        = string

  validation {
    condition     = can(regex("^(\\*\\.)?([a-z0-9]([a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.hostname)) && length(var.hostname) <= 253
    error_message = "hostname must be a valid lowercase DNS hostname, optionally beginning with '*.', and at most 253 characters."
  }
}

variable "regional_acm_certificate_arn" {
  description = "Regional ACM certificate ARN used as the default certificate for the HTTPS:443 ALB listener."
  type        = string

  validation {
    condition     = can(regex("^arn:aws([a-z-]*)?:acm:[a-z0-9-]+:[0-9]{12}:certificate/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.regional_acm_certificate_arn))
    error_message = "regional_acm_certificate_arn must be a valid ACM certificate ARN for an AWS partition and region."
  }
}

variable "private_subnet_ids" {
  description = "At least two distinct private subnet IDs where the internal ALB will be created."
  type        = set(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2 && alltrue([for subnet_id in var.private_subnet_ids : can(regex("^subnet-[0-9a-f]+$", subnet_id))])
    error_message = "private_subnet_ids must contain at least two distinct subnet IDs in the form subnet-<lowercase-hex>."
  }
}

variable "authorized_application_namespaces" {
  description = "Non-empty set of existing application namespaces authorized to attach HTTPRoutes to the Gateway; owned outside this module."
  type        = set(string)

  validation {
    condition     = length(var.authorized_application_namespaces) > 0 && alltrue([for namespace in var.authorized_application_namespaces : can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", namespace)) && length(namespace) <= 63])
    error_message = "authorized_application_namespaces must contain one or more Kubernetes DNS labels of at most 63 lowercase letters, numbers, or hyphens."
  }

  validation {
    condition     = !contains(var.authorized_application_namespaces, var.platform_namespace)
    error_message = "platform_namespace must not also be an authorized application namespace."
  }
}

variable "alb_tags" {
  description = "Optional tags applied by AWS Load Balancer Controller to the managed internal ALB."
  type        = map(string)
  default     = {}
}
