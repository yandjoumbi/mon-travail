import boto3
import os

# Initialize the CloudWatch Logs client
logs_client = boto3.client('logs')

# Lambda environment variable for retention period (in days)
DEFAULT_RETENTION_DAYS = int(os.getenv('DEFAULT_RETENTION_DAYS', '7'))

def set_log_group_retention(log_group_name, retention_days):
    try:
        # Set the retention policy for the log group
        logs_client.put_retention_policy(
            logGroupName=log_group_name,
            retentionInDays=retention_days
        )
        print(f"Set retention for {log_group_name} to {retention_days} days")
    except Exception as e:
        print(f"Error setting retention for {log_group_name}: {str(e)}")


def lambda_handler(event, context):
    log_groups = []

    # Get a list of all CloudWatch log groups
    paginator = logs_client.get_paginator('describe_log_groups')
    for page in paginator.paginate():
        log_groups.extend(page['logGroups'])

    # Set the retention policy for each log group if not already set
    for log_group in log_groups:
        log_group_name = log_group['logGroupName']

        # Check if retention policy is already set
        if 'retentionInDays' not in log_group:
            set_log_group_retention(log_group_name, DEFAULT_RETENTION_DAYS)

    return {
        'statusCode': 200,
        'body': f"Updated retention policies for {len(log_groups)} log groups."
    }

#permisions
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "logs:DescribeLogGroups",
#         "logs:PutRetentionPolicy"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
