# SNS topic
resource "aws_sns_topic" "alarm_topic" {
  name = "my-alarm-topic"
}

# SNS subscription to send notifications to an email address
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = "ydjoumbi@gmail.com"
}

# Define the CloudWatch alarm
# resource "aws_cloudwatch_alarm" "high_cpu_alarm" {
#   alarm_name          = "high-cpu-alarm"
#   alarm_description   = "This alarm triggers when CPU usage exceeds 80%"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   statistic           = "Average"
#   period              = 300
#   evaluation_periods  = 1
#   threshold           = 80
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#
#   # Reference the SNS topic for notifications
#   alarm_actions = [aws_sns_topic.alarm_topic.arn]
#
#   dimensions = {
#     InstanceId =   # Replace with your EC2 instance ID
#   }
# }
