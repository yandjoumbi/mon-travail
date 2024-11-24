data "aws_caller_identity" "current"{

}

# Define an S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "cloudtrail-lambda-logs-yannick"

  # Optional: enable versioning for log retention
  versioning {
    enabled = true
  }

  # Enable server-side encryption for log data
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "CloudTrail Logs Bucket"
    Environment = "Production"
  }
}

# Attach a bucket policy to allow CloudTrail to write logs to the bucket
# Attach a bucket policy to allow CloudTrail to write logs to the bucket
resource "aws_s3_bucket_policy" "cloudtrail_logs_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/*"  # Restrict to the bucket's objects
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      }
    ]
  })
}

# Create the CloudTrail trail to capture Lambda events
resource "aws_cloudtrail" "lambda_trail" {
  name                          = "LambdaInvocationTrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::Lambda::Function"
      values = ["arn:aws:lambda:us-west-2:597647611698:function:ebsSnapshot"]
    }
  }

  tags = {
    Name = "Lambda Invocation Audit Trail"
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail_logs_policy]
}


# Optional: create an SNS topic for CloudTrail log events notifications
resource "aws_sns_topic" "cloudtrail_alerts" {
  name = "cloudtrail-lambda-alerts"

  tags = {
    Name = "CloudTrail Alerts"
  }
}

# Output the S3 bucket name and CloudTrail name
output "cloudtrail_s3_bucket" {
  value = aws_s3_bucket.cloudtrail_logs
}


