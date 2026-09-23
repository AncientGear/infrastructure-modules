output "platform_namespace" {
  description = "Terraform-managed namespace containing the Gateway and LoadBalancerConfiguration."
  value       = kubernetes_namespace_v1.platform.metadata[0].name
}

output "authorized_application_namespaces" {
  description = "Terraform-managed namespaces permitted to attach HTTPRoutes to the Gateway."
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
