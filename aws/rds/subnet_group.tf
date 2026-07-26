resource "aws_db_subnet_group" "default" {
  name       = "${var.env}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = merge(
    {
      Name = "${var.env}-db-subnet-group"
    },
    var.tags
  )
}