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


# create AWS EventBridge for S3 buckets
#resource "aws_cloudwatch_event_rule" "s3_upload_object" {
#  name          = "s3-event-rule"
#  description   = "React to S3 events in the bucket"
#  event_pattern = <<PATTERN
#{
#  "source": ["aws.s3"],
#  "detail-type": ["Object Created"],
#  "resources": ["arn:aws:s3:::example-eventbridge-s3-bucket"],
#  "detail": {
#    "eventName": ["PutObject", "CompleteMultipartUpload"]
#  }
#}
#PATTERN
#}
#
#resource "aws_cloudwatch_event_target" "s3_to_sns" {
#  rule      = aws_cloudwatch_event_rule.s3_upload_object.name
#  target_id = "sns"
#  arn       = aws_sns_topic_policy.sns_policy.arn
#}
#
## Give EventBridge permission to publish to SNS
#resource "aws_sns_topic_policy" "sns_policy" {
#  arn    = aws_sns_topic.alarm_topic.arn
#  policy = <<POLICY
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect": "Allow",
#      "Principal": {
#        "Service": "events.amazonaws.com"
#      },
#      "Action": "SNS:Publish",
#      "Resource": "${aws_sns_topic.alarm_topic.arn}"
#    }
#  ]
#}
#POLICY
#}
