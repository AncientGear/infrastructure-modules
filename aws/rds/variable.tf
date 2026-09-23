variable "allocated_storage" {
  type    = number
  default = 10
}

variable "db_name" {
  type    = string
  default = "my_db"
}

variable "engine" {
  type    = string
  default = "postgres"
}

variable "port" {
  type    = string
  default = "5432"
}

variable "engine_version" {
  type    = string
  default = "15.3"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "username" {
  type    = string
  default = "foo"
}

variable "parameter_group_name" {
  description = "Optional DB parameter group name. When null, AWS uses the engine default parameter group."
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(string)
  default = {
    Name        = "my-rds-instance"
    Environment = "dev"
  }
}

variable "multi_az_enable" {
  type    = bool
  default = false
}

variable "vpc_id" {
  type = string
}

variable "private_db_subnet_ids" {
  type = list(string)
}

variable "allowed_cidr_blocks" {
  type = list(string)
}

variable "env" {
  type    = string
  default = "dev"
}