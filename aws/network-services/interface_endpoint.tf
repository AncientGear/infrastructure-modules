resource "aws_vpc_endpoint" "interface_endpoint" {
  for_each = {
    for ep in var.interface_endpoints :
    "${var.vpc_id}-${ep.service_name}" => ep
  }
  vpc_id            = var.vpc_id
  service_name      = each.value.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.vpc_endpoints[0].id]
  subnet_ids         = each.value.subnet_ids

  private_dns_enabled = each.value.private_dns

  tags = var.interface_endpoint_tags
}