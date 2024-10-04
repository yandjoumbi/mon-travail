# Peering connection from VPC A
resource "aws_vpc_peering_connection" "connection_a_to_b" {
  peer_vpc_id = aws_vpc.vpc_b.id
  vpc_id    = aws_vpc.vpc_a.id

  tags = {
    Name = "Peering connection A to B"
  }
}

resource "aws_vpc_peering_connection" "connection_a_to_c" {
  peer_vpc_id = aws_vpc.vpc_c.id
  vpc_id    = aws_vpc.vpc_a.id

  tags = {
    Name = "Peering connection A to C"
  }
}

# Peering connection from VPC B
resource "aws_vpc_peering_connection" "connection_b_to_a" {
  peer_vpc_id = aws_vpc.vpc_a.id
  vpc_id    = aws_vpc.vpc_b.id

  tags = {
    Name = "Peering connection B to A"
  }
}


resource "aws_vpc_peering_connection" "connection_b_to_c" {
  peer_vpc_id = aws_vpc.vpc_c.id
  vpc_id    = aws_vpc.vpc_b.id

  tags = {
    Name = "Peering connection B to C"
  }
}

# Peering connection from C
resource "aws_vpc_peering_connection" "connection_c_to_a" {
  peer_vpc_id = aws_vpc.vpc_a.id
  vpc_id    = aws_vpc.vpc_c.id

  tags = {
    Name = "Peering connection C to A"
  }
}

resource "aws_vpc_peering_connection" "connection_c_to_b" {
  peer_vpc_id = aws_vpc.vpc_b.id
  vpc_id    = aws_vpc.vpc_c.id

  tags = {
    Name = "Peering connection C to B"
  }
}