provider "aws" {
  region = local.location
}

locals {
  location = "us-west-2"
}

data "aws_key_pair" "key_pair" {
  key_name = "my-key-pair"
}

resource "aws_vpc" "vpc_a" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "VPC A"
  }
}

resource "aws_subnet" "subnet_a_1" {
  vpc_id     = aws_vpc.vpc_a.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "public subnet A"
  }
}

resource "aws_subnet" "subnet_a_2" {
  vpc_id     = aws_vpc.vpc_a.id
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
    cidr_block                = "10.1.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.connection_a_to_b.id
  }

  route {
    cidr_block                = "10.2.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.connection_a_to_c.id
  }

  tags = {
    Name = "Route table A"
  }
}

resource "aws_route_table_association" "route_table_association" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.subnet_a_1.id
}

resource "aws_instance" "server_a" {
  ami                         = "ami-04dd23e62ed049936"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_a_1.id
  key_name                    = data.aws_key_pair.key_pair.key_name
  security_groups             = [aws_security_group.server_sg.id]
  associate_public_ip_address = true
  user_data                   = <<-EOF
  #!/bin/bash
  sudo apt update -y
  EOF

  tags = {
    Name = "Server A"
  }
}

resource "aws_security_group" "server_sg" {
  name        = "server-a-security-group"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.vpc_a.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}