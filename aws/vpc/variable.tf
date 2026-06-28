variable "env" {
  description = "Environment name."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR (Classless Inter-Domain Routing)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones for subnets."
  type        = list(string)
}

variable "private_app_subnets" {
  description = "CIDR ranges for private app subnets."
  type        = list(string)
}
variable "private_app_subnet_tags" {
  description = "Private subnet tags."
  type        = map(any)
}

variable "private_db_subnets" {
  description = "CIDR ranges for private db subnets."
  type       = list(string)
}

variable "private_db_subnet_tags" {
  description = "Private DB subnet tags."
  type        = map(string)
}

variable "public_subnets" {
  description = "CIDR ranges for public subnets."
  type        = list(string)
}

variable "public_subnet_tags" {
  description = "Public subnet tags."
  type        = map(string)
}

variable "vpc_tags" {
  description = "VPC tags"
  type        = map(string)
}