provider "aws" {
  region = local.location
}

data "aws_ami" "ubuntu_ami" {
  owners = ["self"]

  filter {
    name   = "name"
    values = ["yannick-custom-ubuntu-*"]
  }
}

data "aws_key_pair" "key_name" {
  key_name = "my-key-pair"
}

locals {
  instance_type = "t2.small"
  location      = "us-west-2"
  environment   = "dev"
  vpc_cidr      = "10.0.0.0/16"
  ami_id        = data.aws_ami.ubuntu_ami.id
  key_pair_name = data.aws_key_pair.key_name.key_name

  user_data_web = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo docker run -d -p 4200:4200 --name frontend yandjoumbi/angular-python-frontend:3
  EOF

  user_data_app = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo docker run -d -p 5000:5000 --name backend  yandjoumbi/angular-python-backend:3
  EOF
}