

resource "aws_vpc" "vpc_c" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "VPC C"
  }
}

resource "aws_subnet" "subnet_c_1" {
  vpc_id     = aws_vpc.vpc_c.id
  cidr_block = "10.2.0.0/24"

  tags = {
    Name = "public subnet C"
  }
}

resource "aws_subnet" "subnet_c_2" {
  vpc_id     = aws_vpc.vpc_c.id
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

  route {
    cidr_block                = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.connection_c_to_a.id
  }

  route {
    cidr_block                = "10.1.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.connection_c_to_b.id
  }

  tags = {
    Name = "route table C"
  }
}

resource "aws_route_table_association" "route_table_association_c" {
  route_table_id = aws_route_table.route_table_c.id
  subnet_id      = aws_subnet.subnet_c_1.id
}

resource "aws_instance" "server_c" {
  ami                         = "ami-04dd23e62ed049936"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_c_1.id
  key_name                    = data.aws_key_pair.key_pair.key_name
  security_groups             = [aws_security_group.server_sg_c.id]
  associate_public_ip_address = true
  user_data                   = <<-EOF
  #!/bin/bash
  sudo apt update -y
  EOF

  tags = {
    Name = "Server C"
  }
}

resource "aws_security_group" "server_sg_c" {
  name        = "server-c-security-group"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.vpc_c.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
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