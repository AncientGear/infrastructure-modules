locals {
  nat_gateway_count = (
    var.nat_mode == "disabled" ? 0 :
    var.nat_mode == "single" ? 1 :
    length(var.azs)
  )
}

resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  domain = "vpc"

  tags = {
    Name = "${var.env}-nat-${var.azs[count.index]}"
  }
}

resource "aws_nat_gateway" "this" {
  count = local.nat_gateway_count

  allocation_id     = aws_eip.nat[count.index].id
  subnet_id         = aws_subnet.public[count.index].id
  connectivity_type = "public"

  tags = {
    Name = "${var.env}-nat-${var.azs[count.index]}"
  }

  depends_on = [
    aws_internet_gateway.this,
    aws_route_table_association.public,
  ]
}

resource "aws_route" "app_nat" {
  count = var.nat_mode == "disabled" ? 0 : length(var.azs)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.this[
    var.nat_mode == "single" ? 0 : count.index
  ].id
}