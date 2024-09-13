terraform {
  backend "s3" {
    bucket = "terraform-backend-yannick"
    key    = "State-Files/terraform.tfstate"
    region = "us-west-2"
  }
}