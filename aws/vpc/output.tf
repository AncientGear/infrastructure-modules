output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_app_subnet_ids" {
  value = aws_subnet.app_private[*].id
}

output "private_db_subnet_ids" {
  value = aws_subnet.db_private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}