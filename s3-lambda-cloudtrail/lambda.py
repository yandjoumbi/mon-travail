import json

def lambda_handler(event, context):
    print("Event received:", json.dumps(event))

    # Parse the S3 object deletion event
    for record in event.get('detail', {}).get('records', []):
        bucket_name = record.get('s3', {}).get('bucket', {}).get('name')
        object_key = record.get('s3', {}).get('object', {}).get('key')
        print(f"Object deleted: Bucket={bucket_name}, Key={object_key}")

    # Optionally send an alert (e.g., via SNS)
    return {
        "statusCode": 200,
        "body": "Processed S3 deletion event successfully."
    }
