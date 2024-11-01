packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "instance_type" {
  type    = string
  default = "t2.small"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "source_ami" {
  type    = string
  default = "ami-04dd23e62ed049936"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "vpc_id"{
  type = string
  default = "vpc-05a001fd91b0e5fb1"
}

variable "subnet_id"{
  type = string
  default = "subnet-0e962654c615107c0"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

locals {
  ami_name = "yannick-custom-ubuntu-ami-${local.timestamp}"
}

source "amazon-ebs" "ubuntu_ami" {
  ami_name                    = "${local.ami_name}"
  associate_public_ip_address = true
  instance_type               = "${var.instance_type}"
  region                      = "${var.region}"
  source_ami                  = "${var.source_ami}"
  ssh_username                = "${var.ssh_username}"
  subnet_id                   = "${var.subnet_id}"
  tags = {
    BuiltBy = "Packer"
    Name    = "Yannick custom ubuntu"
  }
  vpc_id = "${var.vpc_id}"
}

build {
  sources = ["source.amazon-ebs.ubuntu_ami"]

  provisioner "shell" {
    inline = [
      "sudo apt update -y",
      "sudo apt upgrade -y",

      # Docker installation using docker.io
      "sudo apt install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "docker --version",

      # AWS CLI installation
      "sudo apt install -y curl unzip",
      "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "rm -rf awscliv2.zip aws",
      "aws --version"
    ]
  }

}