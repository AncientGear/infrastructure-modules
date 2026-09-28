output "role_arn" {
  description = "ARN assumed by GitHub Actions to publish images."
  value       = aws_iam_role.publisher.arn
}