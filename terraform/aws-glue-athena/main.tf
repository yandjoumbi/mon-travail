provider "aws" {
  region = var.region
}

data "aws_s3_bucket" "airport_data_bucket" {
  bucket = "all-purposes-yannick-bucket"
}

resource "aws_glue_crawler" "airport_data_crawler" {
  database_name = aws_glue_catalog_database.airport_database.name
  name          = "airport-data-crawler"
  role          = aws_iam_role.glue_role.arn
  table_prefix  = "airport_"
  classifiers   = []

  s3_target {
    path = "s3://${data.aws_s3_bucket.airport_data_bucket.bucket}/data-input/"
  }

  schedule = "cron(0 12 * * ? *)"

  configuration = jsonencode({
    "Version" : 1.0,
    "CrawlerOutput" : {
      "Tables" : {
        "AddOrUpdateBehavior" : "MergeNewColumns"
      }
    }
  })

  depends_on = [aws_glue_catalog_database.airport_database]
}

resource "aws_glue_catalog_database" "airport_database" {
  name = var.glue_database_name
}

# Glue Job definition using Glue Studio (script provided inline)
resource "aws_glue_job" "airport_data_job" {
  name     = "airport-data-job"
  role_arn     = aws_iam_role.glue_role.arn
  command {
    name = "glueetl"
    script_location = "s3://${data.aws_s3_bucket.airport_data_bucket.bucket}/airport-data-script.py"
  }

  # Job properties
  max_capacity = 10
  glue_version = "3.0"
  timeout      = 60

  depends_on = [aws_glue_crawler.airport_data_crawler]

}


resource "aws_iam_role" "glue_role" {
  name = "glue_crawler_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Principal: {
          Service: "glue.amazonaws.com"
        },
        Action: "sts:AssumeRole"
      }
    ]
  })
}



# Attach policies to allow access to S3 and Glue
resource "aws_iam_role_policy" "glue_s3_access" {
  name = "glue_s3_access"
  role = aws_iam_role.glue_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          data.aws_s3_bucket.airport_data_bucket.arn,
          "${data.aws_s3_bucket.airport_data_bucket.arn}/*",
          "arn:aws:s3:::all-purposes-yannick-bucket",
          "arn:aws:s3:::all-purposes-yannick-bucket/airport-data-script.py"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "glue:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "glue_bucket_policy" {
  bucket = data.aws_s3_bucket.airport_data_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.glue_role.arn
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::all-purposes-yannick-bucket",
          "arn:aws:s3:::all-purposes-yannick-bucket/airport-data-script.py"
        ]
      }
    ]
  })
}


#To explore your data and identify data quality issues using AWS Athena, follow these steps. Since you've already set up AWS Glue to catalog your data,
# the next logical step is to create a table in Athena based on the Glue catalog and then run SQL queries to explore the data quality.







