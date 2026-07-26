output "db_endpoint" {
  description = "The endpoint of the RDS database instance"
  value       = aws_db_instance.default.endpoint
}

output "db_port" {
  description = "The port of the RDS database instance"
  value       = aws_db_instance.default.port
}

output "db_id" {
  description = "The ID of the RDS database instance"
  value       = aws_db_instance.default.id
}

output "security_group_id" {
  description = "The SG ID of the RDS database instance"
  value       = aws_security_group.rds.id
}
