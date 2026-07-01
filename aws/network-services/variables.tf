variable "interface_endpoints" {
  description = "List of all Interface endpoints"
  type = list(object({
    private_dns        = bool
    security_group_ids = list(string)
    service_name       = string
    subnet_ids         = list(string)
    vpc_id             = string
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
    vpc_id          = string
  }))
}

variable "gateway_endpoint_tags" {
  description = "Tags to apply to all Gateway endpoints"
  type        = map(string)
}