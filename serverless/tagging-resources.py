import json
import boto3

def lambda_handler(event, context):
    # Define the tag you want to apply
    tag_key = "Environment"
    tag_value = "Production"

    # Initialize AWS clients
    ec2_client = boto3.client('ec2')
    rds_client = boto3.client('rds')

    # Extract information from event (this assumes the event is an EC2 or RDS resource creation)
    resource_id = event['detail']['responseElements']['instanceId'] if 'instanceId' in event['detail']['responseElements'] else None
    db_instance_id = event['detail']['responseElements']['dBInstanceIdentifier'] if 'dBInstanceIdentifier' in event['detail']['responseElements'] else None

    # Auto-tagging EC2 instance
    if resource_id:
        ec2_client.create_tags(
            Resources=[resource_id],
            Tags=[{'Key': tag_key, 'Value': tag_value}]
        )
        return {
            'statusCode': 200,
            'body': f"Successfully tagged EC2 instance {resource_id} with {tag_key}: {tag_value}"
        }

    # Auto-tagging RDS instance
    if db_instance_id:
        rds_client.add_tags_to_resource(
            ResourceName=f"arn:aws:rds:{event['region']}:{event['account']}:db:{db_instance_id}",
            Tags=[{'Key': tag_key, 'Value': tag_value}]
        )
        return {
            'statusCode': 200,
            'body': f"Successfully tagged RDS instance {db_instance_id} with {tag_key}: {tag_value}"
        }

    return {
        'statusCode': 400,
        'body': "No matching resource for tagging."
    }
