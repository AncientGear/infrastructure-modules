output "platform_namespace" {
  description = "Name of the platform namespace owned by this module."
  value       = kubernetes_namespace_v1.platform.metadata[0].name
}

output "authorized_application_namespaces" {
  description = "Names of application namespaces owned and authorized by this module."
  value       = sort(keys(kubernetes_namespace_v1.authorized_application))
}
