# provider.tf
provider "aws" {
  region = var.aws_region
}

data "aws_key_pair" "key_name"{
  key_name = "my-key-pair"
}

# security-group.tf
resource "aws_security_group" "nginx_sg" {
  name        = "nginx_security_group"
  description = "Allow HTTP and SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

# main.tf
resource "aws_instance" "nginx_instance" {
  ami           = "ami-05134c8ef96964280" # ubuntu server
  instance_type = var.instance_type
  key_name      = data.aws_key_pair.key_name
  security_groups = [aws_security_group.nginx_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y docker.io
              amazon-linux-extras install nginx1.12 -y
              systemctl start docker
              systemctl enable docker
              docker pull jenkins/jenkins:latest
              EOF

  tags = {
    Name = "nginx-server"
  }
}

