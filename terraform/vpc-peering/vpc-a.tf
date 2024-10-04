provider "aws" {
  region = local.location
}

locals {
  location = "us-west-2"
}

resource "aws_vpc" "vpc_a" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "VPC A"
  }
}

resource "aws_subnet" "subnet_a_1" {
  vpc_id = aws_vpc.vpc_a.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "public subnet A"
  }
}

resource "aws_subnet" "subnet_a_2" {
  vpc_id = aws_vpc.vpc_a.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "private subnet A"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_a.id

  tags = {
    Name = "internet gateway A"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc_a.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = "10.1.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.connection_a_to_b.id
  }

  route {
    cidr_block = "10.2.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.connection_a_to_c.id
  }

  tags = {
    Name = "Route table A"
  }
}

resource "aws_route_table_association" "route_table_association" {
  route_table_id = aws_route_table.route_table.id
  subnet_id = aws_subnet.subnet_a_1.id
}