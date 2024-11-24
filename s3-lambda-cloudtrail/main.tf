provider "aws" {
  region = var.region
}

data "aws_s3_bucket" "airport_data_bucket" {
  bucket = "all-purposes-yannick-bucket"
}

resource "aws_lambda_function" "cloudtrail_alert" {
  filename         = "lambda.zip" # ZIP file containing the Python code
  function_name    = "cloudtrail-object-delete-alert"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("lambda.zip")
  timeout          = 15
}

resource "aws_cloudwatch_event_rule" "s3_object_deleted_rule" {
  name = "s3-object-deleted-rule"
  description = "Triggers Lambda on S3 object deletion events"
  event_pattern = <<EOF
  {
    "source": ["aws.s3"],
    "detail-type": ["AWS API Call via CloudTrail"],
    "detail": {
      "eventSource": ["s3.amazonaws.com"],
      "eventName": ["DeleteObject"]
    }
  }
  EOF
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.s3_object_deleted_rule.name
  target_id = "cloudtrail-alert-lambda"
  arn       = aws_lambda_function.cloudtrail_alert.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloudtrail_alert.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_object_deleted_rule.arn
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-cloudtrail-alert-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-cloudtrail-alert-policy"
  description = "Policy for Lambda to process CloudTrail events"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
