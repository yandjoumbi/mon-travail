variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "bucket_name" {
  description = "S3 bucket for storing airport data"
  type        = string
  default     = "airport-data-bucket"
}

variable "glue_database_name" {
  description = "Glue database name"
  type        = string
  default     = "airport_database"
}

variable "glue_table_name" {
  description = "Glue table name for airport data"
  type        = string
  default     = "airport_data"
}

variable "athena_workgroup_name" {
  description = "Athena workgroup name"
  type        = string
  default     = "airport_analysis_workgroup"
}
