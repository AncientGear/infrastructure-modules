variable "platform_namespace" {
  description = "Namespace containing the shared platform Gateway and its LoadBalancerConfiguration."
  type        = string
  default     = "gateway-system"

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.platform_namespace)) && length(var.platform_namespace) <= 63
    error_message = "platform_namespace must be a Kubernetes DNS label of at most 63 lowercase letters, numbers, or hyphens."
  }
}

variable "authorized_application_namespaces" {
  description = "Non-empty set of application namespaces authorized to attach HTTPRoutes to the Gateway."
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
