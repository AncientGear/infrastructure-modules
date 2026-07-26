output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_app_subnet_ids" {
  value = aws_subnet.app_private[*].id
}

output "private_db_subnet_ids" {
  value = aws_subnet.db_private[*].id
}

output "private_route_table_id" {
  value = aws_route_table.private.id
}

output "private_app_subnet_cidr_blocks" {
  value = aws_subnet.app_private[*].cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}