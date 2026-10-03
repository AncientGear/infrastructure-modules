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

  validation {
    condition     = length(var.private_app_subnets) == length(var.azs)
    error_message = "private_app_subnets must contain one CIDR range for each availability zone in azs."
  }
}
variable "private_app_subnet_tags" {
  description = "Private subnet tags."
  type        = map(any)
}

variable "private_db_subnets" {
  description = "CIDR ranges for private db subnets."
  type        = list(string)

  validation {
    condition     = length(var.private_db_subnets) == length(var.azs)
    error_message = "private_db_subnets must contain one CIDR range for each availability zone in azs."
  }
}

variable "private_db_subnet_tags" {
  description = "Private DB subnet tags."
  type        = map(string)
}

variable "public_subnets" {
  description = "CIDR ranges for public subnets."
  type        = list(string)

  validation {
    condition     = length(var.public_subnets) == length(var.azs)
    error_message = "public_subnets must contain one CIDR range for each availability zone in azs."
  }
}

variable "public_subnet_tags" {
  description = "Public subnet tags."
  type        = map(string)
}

variable "vpc_tags" {
  description = "VPC tags"
  type        = map(string)
}

variable "nat_mode" {
  description = "NAT topology: disabled, single, or per_az."
  type        = string
  default     = "disabled"

  validation {
    condition     = contains(["disabled", "single", "per_az"], var.nat_mode)
    error_message = "nat_mode must be disabled, single, or per_az."
  }
}
