
## SNS Topic for notifications
#resource "aws_sns_topic" "login_attempts_topic" {
#  name = "login-attempts-alerts"
#}
#
## SNS Subscription for email notifications
#resource "aws_sns_topic_subscription" "email_subscription" {
#  topic_arn = aws_sns_topic.login_attempts_topic.arn
#  protocol  = "email"
#  endpoint  = "your-email@example.com"  # Replace with your email
#}
#
## CloudWatch Log Group (assumes you are already sending logs from /var/log/secure to CloudWatch)
#resource "aws_cloudwatch_log_group" "auth_log_group" {
#  name              = "/var/log/secure"
#  retention_in_days = 7
#}
#
## CloudWatch Metric Filter to detect failed login attempts
#resource "aws_cloudwatch_log_metric_filter" "failed_login_attempts" {
#  name           = "FailedLoginAttempts"
#  log_group_name = aws_cloudwatch_log_group.auth_log_group.name
#
#  # Metric filter pattern for failed password attempts
#  pattern = "[date, time, user, ip, some_text=\"Failed password\"]"
#
#  metric_transformation {
#    name      = "FailedLoginAttempts"
#    namespace = "Authentication"
#    value     = "1"
#  }
#}
#
## CloudWatch Alarm for multiple failed login attempts within a time frame
#resource "aws_cloudwatch_metric_alarm" "failed_login_alarm" {
#  alarm_name          = "MultipleFailedLoginAttempts"
#  comparison_operator = "GreaterThanOrEqualToThreshold"
#  evaluation_periods  = 1
#  threshold           = 3 # Trigger alarm if 3 or more failed login attempts occur
#  metric_name         = aws_cloudwatch_log_metric_filter.failed_login_attempts.metric_transformation[0].name
#  namespace           = aws_cloudwatch_log_metric_filter.failed_login_attempts.metric_transformation[0].namespace
#  period              = 300 # Check every 5 minutes (300 seconds)
#  statistic           = "Sum"
#  alarm_description   = "Triggers when 3 or more failed login attempts occur within 5 minutes."
#
#  # Actions to take when the alarm state changes to ALARM
#  alarm_actions = [aws_sns_topic.login_attempts_topic.arn]
#}
#
## IAM Role for CloudWatch Agent (if not already set up)
#resource "aws_iam_role" "cloudwatch_agent_role" {
#  name = "cloudwatch_agent_role"
#
#  assume_role_policy = jsonencode({
#    Version = "2012-10-17",
#    Statement = [
#      {
#        Action    = "sts:AssumeRole",
#        Effect    = "Allow",
#        Principal = {
#          Service = "ec2.amazonaws.com"
#        }
#      }
#    ]
#  })
#}
#
## Attach the necessary policy to allow CloudWatch logging
#resource "aws_iam_policy_attachment" "cloudwatch_agent_policy_attach" {
#  name       = "cloudwatch-agent-attach"
#  roles      = [aws_iam_role.cloudwatch_agent_role.name]
#  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
#}
#
## IAM instance profile for the EC2 instance
#resource "aws_iam_instance_profile" "ec2_instance_profile" {
#  name = "ec2-instance-profile"
#  role = aws_iam_role.cloudwatch_agent_role.name
#}
#
############

## Create SNS Topic for Alarm Notifications
#resource "aws_sns_topic" "nat_gateway_alarm_topic" {
#  name = "nat-gateway-traffic-alarms"
#}
#
## SNS Subscription for email notifications
#resource "aws_sns_topic_subscription" "email_subscription" {
#  topic_arn = aws_sns_topic.nat_gateway_alarm_topic.arn
#  protocol  = "email"
#  endpoint  = "your-email@example.com"  # Replace with your email
#}
#
## Create a CloudWatch Log Group for VPC Flow Logs (Optional)
#resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
#  name              = "/aws/vpc/flow-logs"
#  retention_in_days = 7
#}
#
## Enable VPC Flow Logs
#resource "aws_flow_log" "vpc_flow_log" {
#  log_group_name = aws_cloudwatch_log_group.vpc_flow_logs.name
#  iam_role_arn   = aws_iam_role.vpc_flow_log_role.arn
#  vpc_id         = aws_vpc.main.id
#  traffic_type   = "ALL"  # Logs all traffic (Ingress and Egress)
#}
#
## IAM Role for VPC Flow Logs
#resource "aws_iam_role" "vpc_flow_log_role" {
#  name = "vpcFlowLogRole"
#
#  assume_role_policy = jsonencode({
#    Version = "2012-10-17",
#    Statement = [
#      {
#        Action    = "sts:AssumeRole",
#        Effect    = "Allow",
#        Principal = {
#          Service = "vpc-flow-logs.amazonaws.com"
#        }
#      }
#    ]
#  })
#}
#
## Attach the CloudWatch policy to the IAM Role
#resource "aws_iam_policy_attachment" "vpc_flow_log_policy_attach" {
#  roles      = [aws_iam_role.vpc_flow_log_role.name]
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforDataPipelineRole"
#}
#
## CloudWatch Alarm for monitoring NAT Gateway outgoing traffic
#resource "aws_cloudwatch_metric_alarm" "nat_gateway_traffic_alarm" {
#  alarm_name          = "HighNATGatewayOutboundTraffic"
#  comparison_operator = "GreaterThanThreshold"
#  evaluation_periods  = 1
#  metric_name         = "BytesOutToDestination"
#  namespace           = "AWS/NATGateway"
#  period              = 300  # Check every 5 minutes (300 seconds)
#  statistic           = "Sum"
#  threshold           = 500000000 # 500 MB
#  alarm_description   = "Alarm when NAT Gateway outbound traffic exceeds 500MB in 5 minutes"
#
#  dimensions = {
#    NatGatewayId = aws_nat_gateway.main.id  # Replace with your NAT Gateway ID
#  }
#
#  # Send notifications to the SNS topic when the alarm is triggered
#  alarm_actions = [aws_sns_topic.nat_gateway_alarm_topic.arn]
#}
#
## NAT Gateway example (replace with your setup)
#resource "aws_nat_gateway" "main" {
#  allocation_id = aws_eip.main.id
#  subnet_id     = aws_subnet.public.id
#}
#
## Example Elastic IP for the NAT Gateway
#resource "aws_eip" "main" {
#  vpc = true
#}
#
## Example VPC and Subnet (replace with your existing setup)
#resource "aws_vpc" "main" {
#  cidr_block = "10.0.0.0/16"
#}
#
#resource "aws_subnet" "public" {
#  vpc_id     = aws_vpc.main.id
#  cidr_block = "10.0.1.0/24"
#}
