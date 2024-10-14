provider "aws" {
  region = local.location
}

locals {
  instance_type = "t2.micro"
  location      = "us-west-2"
  environment   = "dev"
  vpc_cidr      = "10.0.0.0/16"
}

resource "aws_vpc" "security_vpc" {
  cidr_block = local.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Security VPC"
  }
}

resource "aws_subnet" "security_public_subnet_a" {
  vpc_id = aws_vpc.security_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Security Public Subnet A"
  }
}

resource "aws_subnet" "security_public_subnet_b" {
  vpc_id = aws_vpc.security_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Security Public Subnet B"
  }
}

resource "aws_subnet" "security_private_subnet_a" {
  vpc_id = aws_vpc.security_vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Security Private Subnet A"
  }
}

resource "aws_subnet" "security_private_subnet_b" {
  vpc_id = aws_vpc.security_vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Security Private Subnet B"
  }
}

resource "aws_internet_gateway" "security_igw" {
  vpc_id = aws_vpc.security_vpc.id
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.security_public_subnet_a.id

  tags = {
    Name = "main_nat_gateway"
  }
}

## public
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.security_vpc.id
}

resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.security_igw.id
}

resource "aws_route_table_association" "rt_public_association_a" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id = aws_subnet.security_public_subnet_a.id
}

resource "aws_route_table_association" "rt_public_association_b" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id = aws_subnet.security_public_subnet_b.id
}

#### private
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.security_vpc.id
}

resource "aws_route" "private_route" {
  route_table_id = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "private_rt_a" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id = aws_subnet.security_private_subnet_a.id
}

resource "aws_route_table_association" "private_rt_b" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id = aws_subnet.security_private_subnet_b.id
}

resource "aws_lb" "network_lb" {
  name               = "network-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.security_public_subnet_a.id, aws_subnet.security_public_subnet_b.id]

  tags = {
    Name = "network_lb"
  }
}

# Create Web EC2 Instance
resource "aws_instance" "web" {
  ami                         = "ami-12345678" # Update with appropriate AMI
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.security_private_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = false
  tags = {
    Name = "web_instance"
  }
}

# Create Database EC2 Instance
resource "aws_instance" "db" {
  ami                    = "ami-12345678" # Update with appropriate AMI
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.security_private_subnet_b.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  tags = {
    Name = "db_instance"
  }
}

# Security Group for Web Server
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.security_vpc.id
  name   = "web_sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_sg"
  }
}

# Security Group for Database Server
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.security_vpc.id
  name   = "db_sg"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Private traffic only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db_sg"
  }
}


