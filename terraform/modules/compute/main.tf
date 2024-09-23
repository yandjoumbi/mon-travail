# LATEST AMI FROM PARAMETER STORE

data "aws_ami" "amazon_linux2_ami"{
  owners = ["self"]
}

# SSH KEY FOR BASTION HOST

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.ssh_key
  public_key = tls_private_key.main.public_key_openssh
}

resource "local_file" "ssh_key" {
  content         = tls_private_key.main.private_key_pem
  filename        = "${var.ssh_key}.pem"
  file_permission = "0400"
}

# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR BASTION HOST

resource "aws_launch_template" "three_tier_bastion" {
  count                  = var.enable_autoscaling ? 1 : 0
  name_prefix            = "three_tier_bastion"
  instance_type          = var.instance_type
  image_id               = data.aws_ami.amazon_linux2_ami.id
  vpc_security_group_ids = [var.bastion_sg]
  key_name               = var.key_name

  tags = {
    Name = "three_tier_bastion_yannick"
  }
}

resource "aws_autoscaling_group" "three_tier_bastion" {
  count               = var.enable_autoscaling ? 1 : 0
  name                = "three_tier_bastion"
  vpc_zone_identifier = var.public_subnets
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.three_tier_bastion[0].id
    version = "$Latest"
  }
}


# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR FRONTEND APP TIER

resource "aws_launch_template" "three_tier_app" {
  count                  = var.launch_template ? 1 : 0
  name_prefix            = "three_tier_app"
  instance_type          = var.instance_type
  image_id               = data.aws_ami.amazon_linux2_ami.id
  vpc_security_group_ids = [var.frontend_app_sg]
  user_data              = filebase64("install_apache.sh")
  key_name               = var.key_name

  tags = {
    Name = "three_tier_app_yannick"
  }
}

data "aws_lb_target_group" "three_tier_tg" {
  name = var.lb_tg_name
}

resource "aws_autoscaling_group" "three_tier_app" {
  count               = var.enable_autoscaling ? 1 : 0
  name                = "three_tier_app"
  vpc_zone_identifier = var.private_subnets
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  target_group_arns = [data.aws_lb_target_group.three_tier_tg.arn]

  launch_template {
    id      = aws_launch_template.three_tier_app[0].id
    version = "$Latest"
  }
}


# LAUNCH TEMPLATES AND AUTOSCALING GROUPS FOR BACKEND

resource "aws_launch_template" "three_tier_backend" {
  count                  = var.launch_template ? 1 : 0
  name_prefix            = "three_tier_backend"
  instance_type          = var.instance_type
  image_id               = data.aws_ami.amazon_linux2_ami.id
  vpc_security_group_ids = [var.backend_app_sg]
  key_name               = var.key_name
  user_data              = filebase64("install_node.sh")

  tags = {
    Name = "three_tier_backend"
  }
}

resource "aws_autoscaling_group" "three_tier_backend" {
  count               = var.enable_autoscaling ? 1 : 0
  name                = "three_tier_backend"
  vpc_zone_identifier = var.private_subnets
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.three_tier_backend[0].id
    version = "$Latest"
  }
}

# AUTOSCALING ATTACHMENT FOR APP TIER TO LOADBALANCER

resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.three_tier_app[0].id
  lb_target_group_arn    = var.lb_tg
}