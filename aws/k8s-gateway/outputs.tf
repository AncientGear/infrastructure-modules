output "platform_namespace" {
  description = "Namespace containing the Gateway and LoadBalancerConfiguration; owned outside this module."
  value       = var.platform_namespace
}

output "authorized_application_namespaces" {
  description = "Namespace names permitted to attach HTTPRoutes to the Gateway; owned outside this module."
  value       = sort(tolist(var.authorized_application_namespaces))
}

output "route_authorization_label" {
  description = "Label selector that an application namespace must retain to attach HTTPRoutes to this Gateway."
  value       = local.route_authorization_label
}

output "gateway_class_name" {
  description = "Name of the Terraform-managed GatewayClass."
  value       = var.gateway_class_name
}

output "gateway_name" {
  description = "Name of the Terraform-managed internal HTTPS Gateway."
  value       = var.gateway_name
}

output "load_balancer_configuration_name" {
  description = "Name of the Terraform-managed AWS LoadBalancerConfiguration."
  value       = var.load_balancer_configuration_name
}
