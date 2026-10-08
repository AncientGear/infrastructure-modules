output "role_arn" {
  value = aws_iam_role.runtime.arn
}

output "secret_name" {
  value = "backend-runtime"
}