output "namespace" {
  description = "Namespace of the operator release, not application secrets."
  value       = helm_release.external_secrets.namespace
}

output "release_name" {
  description = "Operator release owning ESO CRDs."
  value       = helm_release.external_secrets.name
}
