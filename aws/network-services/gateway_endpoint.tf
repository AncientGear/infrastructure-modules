resource "aws_vpc_endpoint" "gateway_endpoints" {
  for_each = {
    for ep in var.interface_endpoints :
    "${ep.vpc_id}-${ep.service_name}" => ep
  }
  vpc_id            = each.value.vpc_id
  service_name      = each.value.service_name
  vpc_endpoint_type = "Gateway"

  route_table_ids = each.value.route_table_ids
  policy          = each.value.policy_json

  tags = var.gateway_endpoint_tags
}