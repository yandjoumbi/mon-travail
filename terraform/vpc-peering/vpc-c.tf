

resource "aws_vpc" "vpc_c" {
  count = var.vpc_enabled ? 1 : 0
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "VPC C"
  }
}

resource "aws_subnet" "subnet_c_1" {
  vpc_id = aws_vpc.vpc_c.id
  cidr_block = "10.2.0.0/24"

  tags = {
    Name = "public subnet C"
  }
}

resource "aws_subnet" "subnet_c_2" {
  vpc_id = aws_vpc.vpc_c.id
  cidr_block = "10.2.1.0/24"

  tags = {
    Name = "private subnet C"
  }
}

resource "aws_internet_gateway" "igw_c" {
  vpc_id = aws_vpc.vpc_c.id

  tags = {
    Name = "igw C"
  }
}

resource "aws_route_table" "route_table_c" {
  vpc_id = aws_vpc.vpc_c.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_c.id
  }

  tags = {
    Name = "route table C"
  }
}

resource "aws_route_table_association" "route_table_association_c" {
  route_table_id = aws_route_table.route_table_c.id
  subnet_id = aws_subnet.subnet_c_1.id
}