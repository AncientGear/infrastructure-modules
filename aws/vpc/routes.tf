resource "aws_route_table" "private" {
  count = length(var.azs)

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.env}-private"
  }
}

moved {
  from = aws_route_table.private
  to   = aws_route_table.private[0]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.env}-public"
  }
}

resource "aws_route_table_association" "app_private" {
  count = length(var.private_app_subnets)

  subnet_id      = aws_subnet.app_private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "db_private" {
  count = length(var.private_db_subnets)

  subnet_id      = aws_subnet.db_private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
