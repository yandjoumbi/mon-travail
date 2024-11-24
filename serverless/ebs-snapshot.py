import json
import boto3
import datetime
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize boto3 clients
ec2_client = boto3.client('ec2')
s3_client = boto3.client('s3')
s2_client = boto3.

# Set your EBS volume ID and S3 bucket name
EBE_VOLUME_IDS = ['vol-0f2e9cd33f9f28ce6', '']
S3_BUCKET_NAME = 'all-purposes-yannick-bucket'

def lambda_handler(event, context):
    for ebe_volume_id in EBE_VOLUME_IDS:
        try:
        # Take snapshot of the EBS volume
            snapshot = ec2_client.create_snapshot(
                VolumeId=ebe_volume_id,
                Description='Snapshot taken by Lambda function for volume {ebe_volume_id}'
            )

        # Log snapshot details
            logger.info(f'Snapshot created with ID: {snapshot["SnapshotId"]} for volume {ebe_volume_id}')

        # Prepare the metadata to store in S3
            snapshot_metadata = {
                'SnapshotId': snapshot['SnapshotId'],
                'VolumeId': ebe_volume_id,
                'StartTime': str(snapshot['StartTime']),
                'Description': snapshot['Description']
            }

            # Define the S3 object key
            timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
            s3_object_key = f'snapshots/snapshot-{snapshot["SnapshotId"]}-{timestamp}.json'

            # Upload snapshot metadata to S3
            s3_client.put_object(
                Bucket=S3_BUCKET_NAME,
                Key=s3_object_key,
                Body=json.dumps(snapshot_metadata),
                ContentType='application/json'
            )

        logger.info(f'Snapshot metadata uploaded to S3 at {s3_object_key}')

        return {
            'statusCode': 200,
            'body': json.dumps(f'Snapshot for volume {ebe_volume_id} created and metadata stored successfully.')
        }

    except Exception as e:
        logger.error(f'Error creating volume {ebe_volume_id} snapshot or uploading metadata: {str(e)}')
        return {
            'statusCode': 500,
            'body': json.dumps('Error creating snapshot.')
        }


# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "ec2:CreateSnapshot",
#                 "ec2:DescribeVolumes",
#                 "s3:PutObject"
#             ],
#             "Resource": "*"
#         }
#     ]
# }
