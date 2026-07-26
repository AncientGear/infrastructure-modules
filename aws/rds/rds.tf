resource "aws_db_instance" "default" {
  allocated_storage           = var.allocated_storage
  db_name                     = var.db_name
  engine                      = var.engine
  engine_version              = var.engine_version
  port                        = var.port
  instance_class              = var.instance_class
  username                    = var.username
  manage_master_user_password = true
  parameter_group_name        = var.parameter_group_name
  skip_final_snapshot         = var.skip_final_snapshot
  tags = merge(
    {
      Name = "${var.env}-rds"
    },
    var.tags
  )

  multi_az = var.multi_az_enable

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name     = aws_db_subnet_group.default.name
}