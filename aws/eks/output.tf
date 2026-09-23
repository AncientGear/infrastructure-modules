output "eks_name" {
  value = aws_eks_cluster.this.name
}

output "openid_provider_arn" {
  description = "ARN of the IAM OIDC provider created for IRSA, or null when IRSA is disabled."
  value       = try(aws_iam_openid_connect_provider.this[0].arn, null)
}

output "oidc_provider_arn" {
  description = "Alias for openid_provider_arn, matching IAM role module input naming. Null when IRSA is disabled."
  value       = try(aws_iam_openid_connect_provider.this[0].arn, null)
}

output "oidc_provider_url" {
  description = "OIDC issuer URL for the EKS cluster."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
