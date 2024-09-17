import boto3
import os
import time

# Initialize clients for CloudWatch Logs and S3
logs_client = boto3.client('logs')

def lambda_handler(event, context):
    # S3 bucket and prefix for the export (set as environment variables)
    s3_bucket = os.getenv('S3_BUCKET')
    s3_prefix = os.getenv('S3_PREFIX', 'cloudwatch-logs/')

    # Get the current timestamp
    end_time = int(time.time() * 1000)
    # Define the start time (e.g., 24 hours ago)
    start_time = end_time - 86400000  # 24 hours in milliseconds

    # Get a list of all CloudWatch log groups
    log_groups = []
    paginator = logs_client.get_paginator('describe_log_groups')
    for page in paginator.paginate():
        log_groups.extend(page['logGroups'])

    # Export logs for each log group
    for log_group in log_groups:
        log_group_name = log_group['logGroupName']
        print(f"Exporting log group: {log_group_name}")

        # Check if there is an ongoing export task for the log group
        existing_tasks = logs_client.describe_export_tasks(
            statusCode='PENDING'
        )
        if any(task['logGroupName'] == log_group_name for task in existing_tasks['exportTasks']):
            print(f"Skipping log group {log_group_name} because an export task is still in progress.")
            continue

        try:
            # Create the export task
            response = logs_client.create_export_task(
                taskName=f"export-{log_group_name}-{int(time.time())}",
                logGroupName=log_group_name,
                fromTime=start_time,
                to=end_time,
                destination=s3_bucket,
                destinationPrefix=f"{s3_prefix}/{log_group_name}"
            )
            print(f"Created export task for {log_group_name}: {response['taskId']}")
        except Exception as e:
            print(f"Error exporting log group {log_group_name}: {str(e)}")

    return {
        'statusCode': 200,
        'body': 'Log export tasks created successfully'
    }

# IAM policy
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "logs:CreateExportTask",
#         "logs:DescribeLogGroups",
#         "logs:DescribeExportTasks"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "s3:PutObject",
#         "s3:GetBucketLocation"
#       ],
#       "Resource": "arn:aws:s3:::your-s3-bucket-name/*"
#     }
#   ]
# }
