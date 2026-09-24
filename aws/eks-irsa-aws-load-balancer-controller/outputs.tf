output "role_arn" {
  value       = aws_iam_role.this.arn
  description = "The ARN of the IAM role for the AWS Load Balancer Controller"
}

output "role_name" {
  value       = aws_iam_role.this.name
  description = "The name of the IAM role for the AWS Load Balancer Controller"
}

output "namespace" {
  value       = var.namespace
  description = "The namespace where the AWS Load Balancer Controller will be deployed"
}

output "service_account_name" {
  value       = var.service_account_name
  description = "The name of the service account for the AWS Load Balancer Controller"
}

output "policy_arn" {
  value       = values(aws_iam_policy.aws_load_balancer_controller)[0].arn
  description = "The ARN of the first IAM policy attached to the AWS Load Balancer Controller role. Prefer policy_arns for the complete set."
}

output "policy_arns" {
  value       = { for name, policy in aws_iam_policy.aws_load_balancer_controller : name => policy.arn }
  description = "ARNs of all IAM policies attached to the AWS Load Balancer Controller role."
}
