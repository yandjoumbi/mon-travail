# Load Balancer for Web and Application Layers
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = [aws_subnet.app_public_subnet_1.id, aws_subnet.app_public_subnet_2.id]
  ip_address_type    = "ipv4"
}

# Target Group for Web Layer
resource "aws_lb_target_group" "web_tg" {
  name        = "web-tg"
  port        = 4200
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app_vpc.id
  target_type = "instance"

  health_check {
    enabled             = true
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# Target Group for App Layer
resource "aws_lb_target_group" "app_tg" {
  name        = "app-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app_vpc.id
  target_type = "instance"

  health_check {
    enabled             = true
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# Listener for Load Balancer
resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

# Listener Rule for Web Layer
resource "aws_lb_listener_rule" "web_listener_rule" {
  listener_arn = aws_lb_listener.app_lb_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }

  condition {
    path_pattern {
      values = ["/web/*"]
    }
  }
}

# Listener Rule for App Layer
resource "aws_lb_listener_rule" "app_listener_rule" {
  listener_arn = aws_lb_listener.app_lb_listener.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  condition {
    path_pattern {
      values = ["/app/*"]
    }
  }
}

# Launch Template for Web Layer
resource "aws_launch_template" "web_lt" {
  name          = "web-lt"
  instance_type = local.instance_type
  image_id      = local.ami_id
  key_name      = local.key_pair_name
  user_data     = base64encode(local.user_data_web)

  network_interfaces {
    security_groups             = [aws_security_group.web_sg.id]
    associate_public_ip_address = true
  }

  tags = {
    Name = "Web Instance"
  }
}

# Auto Scaling Group for Web Layer
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.app_public_subnet_1.id, aws_subnet.app_public_subnet_2.id]
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
  image_id      = local.ami_id
  key_name      = local.key_pair_name
  user_data     = base64encode(local.user_data_app)

  network_interfaces {
    security_groups             = [aws_security_group.app_sg.id]
    associate_public_ip_address = true
  }

  tags = {
    Name = "Application Instance"
  }
}

# Auto Scaling Group for App Layer
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.app_private_subnet_1.id, aws_subnet.app_private_subnet_2.id]
  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]
}
