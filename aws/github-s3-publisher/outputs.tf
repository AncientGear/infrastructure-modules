output "role_arn" {
  description = "ARN assumed by GitHub Actions to publish frontend releases."
  value       = aws_iam_role.publisher.arn
}