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
  default = "t2.micro"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "source_ami" {
  type    = string
  default = "ami-0c00d3cdac3e96ae2"
}

variable "ssh_username" {
  type    = string
  default = "ec2-user"
}

variable "vpc_id"{
  type = string
  default = "vpc-05a001fd91b0e5fb1"
}

variable "subnet_id"{
  type = string
  default = "subnet-0e962654c615107c0"
}

# Docker credentials
variable "docker_login" {
  type    = string
  default = "yandjoumbi"
}

variable "docker_password" {
  type    = string
  default = "Westland@1987"
}

variable "docker_registry" {
  type    = string
  default = "yandjoumbi"
}


locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

locals {
  ami_name = "yannick-custom-amazon-linux-2-ami-${local.timestamp}"
}

source "amazon-ebs" "amazon_linux2_ami" {
  ami_name                    = "${local.ami_name}"
  associate_public_ip_address = true
  instance_type               = "${var.instance_type}"
  region                      = "${var.region}"
  source_ami                  = "${var.source_ami}"
  ssh_username                = "${var.ssh_username}"
  subnet_id                   = "${var.subnet_id}"
  tags = {
    BuiltBy = "Packer"
    Name    = "Amazon Linux 2 AMI"
  }
  vpc_id = "${var.vpc_id}"
}

build {
  sources = ["source.amazon-ebs.amazon_linux2_ami"]

  provisioner "shell" {
    inline = [
#    "sudo yum update -y",
#    "sudo amazon-linux-extras install docker -y",
#    "sudo systemctl enable docker",
#    "sudo systemctl start docker",
#    "sudo yum install -y python3",
#    "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip' ",
#    "unzip awscliv2.zip",
#    "sudo ./aws/install",
#    "rm -rf awscliv2.zip aws",
#    "sudo amazon-linux-extras enable corretto11",
#    "sudo yum install -y java-11-amazon-corretto",
#      "sudo yum install -y git"

      # Docker login and image pull terraform
#      "sudo docker login -u ${var.docker_login} -p ${var.docker_password} ${var.docker_registry}",
#      "sudo docker pull ${var.docker_registry}/custom-terraform-image:latest",

      # Pull my custom portfolio image
#      "docker pull ${var.docker_registry}/yannick-portfolio:v3"

      # Install Docker with logging
      "sudo yum update -y || { echo \"Yum update failed\"; exit 1; }",
      "sudo amazon-linux-extras install docker -y || { echo \"Docker installation failed\"; exit 1; } ",
      "sudo systemctl enable docker || { echo \"Failed to enable Docker\"; exit 1; }",
      "sudo systemctl start docker || { echo \"Failed to start Docker\"; exit 1; }",

      # Install AWS CLI
      "curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\" || { echo \"Failed to download AWS CLI\"; exit 1; }",
      "unzip awscliv2.zip || { echo \"Failed to unzip AWS CLI\"; exit 1; }",
      "sudo ./aws/install || { echo \"AWS CLI installation failed\"; exit 1; }",
      "rm -rf awscliv2.zip aws || { echo \"Failed to clean up AWS CLI installation files\"; exit 1; }"
    ]
  }

}
