data "aws_availability_zones" "available" {
}

resource "aws_vpc" "three_tier_vpc" {
  count = var.vpc_enabled ? 1 : 0
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "three-tier-vpc-yannick"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#Internet Gateway
resource "aws_internet_gateway" "three_tier_igw" {
  count  = var.vpc_enabled ? 1 : 0
  vpc_id = aws_vpc.three_tier_vpc[0].id

  tags = {
    Name = "igw-yannick"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Public subnets and associated Route tables
resource "aws_subnet" "three_tier_public_subnet" {
  count = var.vpc_enabled ? var.public_sn_count : 0
  vpc_id = aws_vpc.three_tier_vpc[0].id
  cidr_block = "10.123.${10 + count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public-subnet-yannick"
  }
}

resource "aws_route_table" "public_subnet_rt" {
  vpc_id = aws_vpc.three_tier_vpc[0].id

  tags = {
    Name = "public-rt-yannick"
  }
}

resource "aws_route" "default_public_rt" {
  route_table_id = aws_route_table.public_subnet_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.three_tier_igw[0].id
}

resource "aws_route_table_association" "three_tier_public_association" {
  count = var.vpc_enabled ? var.public_sn_count : 0
  route_table_id = aws_route_table.public_subnet_rt.id
  subnet_id = aws_subnet.three_tier_public_subnet.*.id[count.index]
}

### EIP AND NAT GATEWAY

resource "aws_eip" "three_tier_nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "three_tier_ngw" {
  allocation_id     = aws_eip.three_tier_nat_eip.id
  subnet_id         = aws_subnet.three_tier_public_subnet[1].id
}

### PRIVATE SUBNETS (APP TIER & DATABASE TIER) AND ASSOCIATED ROUTE TABLES

resource "aws_subnet" "three_tier_private_subnets" {
  count                   = var.vpc_enabled ? var.public_sn_count : 0
  vpc_id                  = aws_vpc.three_tier_vpc[0].id
  cidr_block              = "10.123.${20 + count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "three_tier_private_yannick"
  }
}

resource "aws_route_table" "three_tier_private_rt" {
  vpc_id = aws_vpc.three_tier_vpc[0].id

  tags = {
    Name = "three_tier_private_yannick"
  }
}

resource "aws_route" "default_private_route" {
  route_table_id         = aws_route_table.three_tier_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.three_tier_ngw.id
}


resource "aws_route_table_association" "three_tier_private_assoc" {
  count          = var.vpc_enabled ? var.public_sn_count : 0
  route_table_id = aws_route_table.three_tier_private_rt.id
  subnet_id      = aws_subnet.three_tier_private_subnets.*.id[count.index]
}


resource "aws_subnet" "three_tier_private_subnets_db" {
  count                   = var.vpc_enabled ? var.public_sn_count : 0
  vpc_id                  = aws_vpc.three_tier_vpc[0].id
  cidr_block              = "10.123.${40 + count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "three_tier_private_db_yannick"
  }
}

### SECURITY GROUPS

resource "aws_security_group" "three_tier_bastion_sg" {
  name        = "three_tier_bastion_sg"
  description = "Allow SSH Inbound Traffic From Set IP"
  vpc_id      = aws_vpc.three_tier_vpc[0].id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.access_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "three_tier_lb_sg" {
  name        = "three_tier_lb_sg"
  description = "Allow Inbound HTTP Traffic"
  vpc_id      = aws_vpc.three_tier_vpc[0].id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "three_tier_frontend_app_sg" {
  name        = "three_tier_frontend_app_sg"
  description = "Allow SSH inbound traffic from Bastion, and HTTP inbound traffic from loadbalancer"
  vpc_id      = aws_vpc.three_tier_vpc[0].id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_bastion_sg.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "three_tier_backend_app_sg" {
  name        = "three_tier_backend_app_sg"
  vpc_id      = aws_vpc.three_tier_vpc[0].id
  description = "Allow Inbound HTTP from FRONTEND APP, and SSH inbound traffic from Bastion"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_frontend_app_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "three_tier_rds_sg" {
  name        = "three-tier_rds_sg"
  description = "Allow MySQL Port Inbound Traffic from Backend App Security Group"
  vpc_id      = aws_vpc.three_tier_vpc[0].id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_backend_app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


### DATABASE SUBNET GROUP

resource "aws_db_subnet_group" "three_tier_rds_subnetgroup" {
  count      = var.db_subnet_group == true ? 1 : 0
  name       = "three_tier_rds_subnetgroup"
  #subnet_ids = [aws_subnet.three_tier_private_subnets_db[0].id, aws_subnet.three_tier_private_subnets_db[1].id]
  subnet_ids = tolist(aws_subnet.three_tier_private_subnets_db.*.id)

  tags = {
    Name = "three_tier_rds_sng"
  }
}

