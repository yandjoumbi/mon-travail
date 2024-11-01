provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "amazon_linux2_ami" {
  owners = ["self"]
}

data "aws_key_pair" "key_name" {
  key_name = "my-key-pair"
}

locals {
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y unzip

    # Install AWS CLI if not already installed
    if ! command -v aws &> /dev/null; then
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
    fi

    # Retrieve credentials from SSM
#    ACCESS_KEY=$(aws ssm get-parameter --name "MY_ACCESS_KEY" --with-decryption --query "Parameter.Value" --output text --region us-west-2)
#    SECRET_KEY=$(aws ssm get-parameter --name "MY_SECRET_KEY" --with-decryption --query "Parameter.Value" --output text --region us-west-2)
#    ACCESS_KEY=$"AKIAYWJUS24ZDAW3FFFF"
#    SECRET_KEY=$"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"
#
#    # Configure AWS CLI with retrieved credentials
#    aws configure set aws_access_key_id "$ACCESS_KEY"
#    aws configure set aws_secret_access_key "$SECRET_KEY"
#    aws configure set default.region "us-west-2"

    aws configure set aws_access_key_id "AKIAYWJUS24ZDAW3FFFF"
    aws configure set aws_secret_access_key "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"
    aws configure set default.region "us-west-2"

    # Download all zip files from s3 bucket to the current directory

    aws s3 cp s3://all-purposes-yannick-bucket/ . --recursive --exclude "*" --include "*.zip"

    sudo apt-get install -y unzip nginx python3 python3-pip python3-venv
    cd /var/www/html

    # Unzip frontend and backend zip files
    unzip frontend.zip
    unzip backend.zip

    # Remove the zip files and the default Nginx welcome page
    rm -rf *.zip index.nginx-debian.html

    # Move contents of the frontend directory to the html directory
    mv frontend/* .

    # Setup and run the Python backend application
    cd backend

    # Create a virtual environment (optional but recommended)
    python3 -m venv venv
    source venv/bin/activate

    # Install backend dependencies (assuming requirements.txt exists)
    pip install -r requirements.txt

    # Start the backend application
    # Replace 'app.py' with your application's entry point
    nohup python app.py &

    # Enable and restart the Nginx service
    sudo systemctl enable nginx
    sudo systemctl restart nginx

    # Optional: Clean up the frontend directory if desired
    rm -rf frontend

    echo "Nginx is set up and serving files from /var/www/html"

  EOF
}


resource "aws_instance" "test_instance" {
  ami = "ami-04dd23e62ed049936"
  instance_type = "t2.micro"
  user_data = base64encode(local.user_data)
  key_name = data.aws_key_pair.key_name.key_name
  vpc_security_group_ids = [aws_security_group.test_security_group.id]
  associate_public_ip_address = true

  tags = {
    Name = "testing"
  }
}

resource "aws_security_group" "test_security_group" {
  description = "Allow HTTP and HTTPS for ALB Only"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "testing security groups"
  }
}