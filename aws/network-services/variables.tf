variable "interface_endpoints" {
  description = "List of all Interface endpoints"
  type = list(object({
    private_dns  = bool
    service_name = string
    subnet_ids   = list(string)
  }))
}

variable "interface_endpoint_tags" {
  description = "Tags to apply to all Interface endpoints"
  type        = map(string)
}

variable "gateway_endpoints" {
  description = "List of all Gateway endpoints"
  type = list(object({
    route_table_ids = list(string)
    policy_json     = optional(string)
    service_name    = string
  }))
}

variable "gateway_endpoint_tags" {
  description = "Tags to apply to all Gateway endpoints"
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC ID where the endpoints will be created"
  type        = string

}

variable "cidr_blocks" {
  description = "List of CIDR blocks to allow access to the VPC endpoints security group"
  type        = list(string)
}

variable "subnet_tags" {
  description = "Tags to apply to all subnets"
  type        = map(string)
  default     = { Name = "vpc-endpoints-sg" }
}