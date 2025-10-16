import boto3
import os
from botocore.exceptions import ClientError

def increment_counter():
    """
    Increment visitor counter in DynamoDB and return the new count.
    This matches the S3 Lambda implementation functionality.
    
    Returns:
        int: The new visitor count after incrementing
        
    Raises:
        Exception: If there's an error accessing DynamoDB
    """
    try:
        # Initialize DynamoDB resource (similar to S3 Lambda implementation)
        region = os.environ.get('AWS_REGION', 'eu-west-1')
        dynamodb = boto3.resource('dynamodb', region_name=region)
        table_name = os.environ.get('TABLE_NAME', 'ec2_ResumeVisitorCount')  # Use env var like S3 version
        table = dynamodb.Table(table_name)
        
        # Get current count first
        response = table.get_item(Key={'id': 'resume'})
        
        # If item doesn't exist, start with 0
        current_count = 0
        if 'Item' in response:
            current_count = response['Item'].get('count', 0)
        
        # Increment count
        new_count = current_count + 1
        
        # Update count in DynamoDB
        table.put_item(
            Item={
                'id': 'resume',
                'count': new_count
            }
        )
        
        return new_count
        
    except ClientError as e:
        print(f"DynamoDB error: {e}")
        raise Exception(f"Database error: {str(e)}")
    except Exception as e:
        print(f"Unexpected error: {e}")
        raise Exception(f"Internal server error: {str(e)}")

def get_count():
    """
    Get current visitor count from DynamoDB.
    
    Returns:
        int: Current visitor count
        
    Raises:
        Exception: If there's an error accessing DynamoDB
    """
    try:
        # Initialize DynamoDB resource
        region = os.environ.get('AWS_REGION', 'eu-west-1')
        dynamodb = boto3.resource('dynamodb', region_name=region)
        table_name = os.environ.get('TABLE_NAME', 'ec2_ResumeVisitorCount')
        table = dynamodb.Table(table_name)
        
        # Get current count
        response = table.get_item(Key={'id': 'resume'})
        
        if 'Item' in response:
            return response['Item'].get('count', 0)
        
        return 0
        
    except ClientError as e:
        print(f"DynamoDB error: {e}")
        raise Exception(f"Database error: {str(e)}")
    except Exception as e:
        print(f"Unexpected error: {e}")
        raise Exception(f"Internal server error: {str(e)}")