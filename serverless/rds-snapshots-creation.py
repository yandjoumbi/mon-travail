import boto3
import os
from datetime import datetime

def lambda_handler(event, context):
    rds_client = boto3.client('rds')

    # The RDS instance you want to snapshot
    db_instance_id = os.environ['DB_INSTANCE_IDENTIFIER']

    # Generate a snapshot identifier
    snapshot_identifier = f"{db_instance_id}-snapshot-{datetime.now().strftime('%Y-%m-%d-%H-%M-%S')}"

    # Create the snapshot
    response = rds_client.create_db_snapshot(
        DBSnapshotIdentifier=snapshot_identifier,
        DBInstanceIdentifier=db_instance_id
    )

    return {
        'statusCode': 200,
        'body': f"RDS snapshot {snapshot_identifier} created successfully."
    }
