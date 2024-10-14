

resource "aws_s3_bucket" "bucket_for_static_web" {
  bucket = "bucket-static-web"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }

}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket_for_static_web.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Effect    = "Allow"
        Resource  = "${aws_s3_bucket.bucket_for_static_web.arn}/*"
        Principal = "*"
        Condition = {
          Bool = {
            "aws:SecureTransport" = "true"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "s3_access_policy" {
  name = "S3AccessPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.bucket_for_static_web.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role" "my_role" {
  name = "s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"  # The service or user assuming the role (e.g., EC2 instance)
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.my_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}