provider "aws" {
  region = local.location
}

locals {
  instance_type = "t2.small"
  location      = "us-west-2"
  environment   = "dev"
  vpc_cidr      = "10.0.0.0/16"
}