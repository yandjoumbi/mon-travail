
# VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = local.vpc_cidr
}

# private and public subnets
resource "aws_subnet" "app_private_subnet_1" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = "10.0.0.0/18"
}

resource "aws_subnet" "app_private_subnet_2" {
  vpc_id     = aws_vpc.app_vpc.id
  cidr_block = "10.0.64.0/18"
}

resource "aws_subnet" "app_public_subnet_1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.128.0/18"
  availability_zone = "us-west-2a"
}

resource "aws_subnet" "app_public_subnet_2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.0.192.0/18"
  availability_zone = "us-west-2b"
}

# internet gateway
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
}

# Nat gateway
#resource "aws_eip" "app_nat_eip" {
#  vpc = true
#}
#
#resource "aws_nat_gateway" "app_ngw" {
#  allocation_id = aws_eip.app_nat_eip.id
#  subnet_id     = aws_subnet.app_public_subnet_1.id
#}

# route tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.app_vpc.id

  #  route {
  #    cidr_block     = "0.0.0.0/0"
  #    nat_gateway_id = aws_nat_gateway.app_ngw.id
  #  }
}

resource "aws_route_table_association" "public_rt_asso_1" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.app_public_subnet_1.id
}

resource "aws_route_table_association" "public_rt_asso_2" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.app_public_subnet_2.id
}

resource "aws_route_table_association" "private_rt_asso_1" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.app_private_subnet_1.id
}

resource "aws_route_table_association" "private_rt_asso_2" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.app_private_subnet_2.id
}