data "aws_s3_bucket" "my_bucket" {
  bucket = "terraform-backend-yannick"
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for CloudFront to access the S3 bucket"
}

# Create CloudFront Distribution
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = data.aws_s3_bucket.my_bucket.bucket_regional_domain_name
    origin_id   = "terraform-backend-yannick"


    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "terraform-backend-yannick"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true  # Set to false and provide ACM certificate ARN for custom domain SSL
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_100"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = data.aws_s3_bucket.my_bucket.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        },
        Action    = "s3:GetObject",
        Resource  = "arn:aws:s3:::terraform-backend-yannick/*"
      }
    ]
  })
}


# Output the CloudFront URL to access the website
output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

# updated bucket policy Create a CloudFront Origin Access Identity,
# s3_origin_config => origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
# Update the S3 Bucket Policy to Allow Access from OAI:
#
# Security: CDNs offer protection against DDoS attacks, provide secure data transmission through SSL/TLS,
#   and can include additional security features like web application firewalls (WAF) to safeguard content and user data
#
# Improved Website Performance: CDNs reduce latency by caching content at edge locations close to users,
#resulting in faster load times and a smoother browsing experience
#