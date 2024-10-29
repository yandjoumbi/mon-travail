data "aws_ami" "amazon_linux2_ami"{
  owners = ["self"]
}

data "aws_key_pair" "key_name"{
  key_name = "my-key-pair"
}

# Load Balancer for Web Layer
resource "aws_lb" "web_lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.app_public_subnet_1.id, aws_subnet.app_public_subnet_2.id]
}

# Target Group for Web Layer
resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.app_vpc.id
}

# Listener for Load Balancer
resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Launch Template for Web Layer
resource "aws_launch_template" "web_lt" {
  name          = "web-lt"
  instance_type = local.instance_type
  image_id      = data.aws_ami.amazon_linux2_ami.id
  key_name               = data.aws_key_pair.key_name.key_name
  security_group_names = [aws_security_group.web_sg.id]
}

# Auto Scaling Group for Web Layer
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity     = 2
  max_size             = 4
  min_size             = 2
  vpc_zone_identifier  = [aws_subnet.app_public_subnet_1.id, aws_subnet.app_public_subnet_2.id]
  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web_tg.arn]
}

# Launch Template for App Layer
resource "aws_launch_template" "app_lt" {
  name          = "app-lt"
  instance_type = local.instance_type
  image_id      = data.aws_ami.amazon_linux2_ami.id
  key_name               = data.aws_key_pair.key_name.key_name
  security_group_names = [aws_security_group.app_sg.id]
}

# Auto Scaling Group for App Layer
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity     = 2
  max_size             = 4
  min_size             = 2
  vpc_zone_identifier  = [aws_subnet.app_private_subnet_1.id, aws_subnet.app_private_subnet_2.id]
  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
}
