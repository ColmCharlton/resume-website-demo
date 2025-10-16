import json
import boto3
import os
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    """
    Lambda function to handle visitor count increment for resume website.
    This function increments the visitor count in DynamoDB and returns the updated count.
    
    Returns:
        dict: Response with statusCode, body containing count, and CORS headers
    """
    
    # Initialize DynamoDB resource
    dynamodb = boto3.resource('dynamodb')
    table_name = os.environ.get('TABLE_NAME', 'ec2_ResumeVisitorCount')  # Use env var like S3 version
    table = dynamodb.Table(table_name)

    try:
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
        
        return {
            'statusCode': 200,
            'body': json.dumps({'count': new_count}),
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET,OPTIONS'
            }
        }
        
    except ClientError as e:
        print(f"DynamoDB error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Database error: {str(e)}'}),
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET,OPTIONS'
            }
        }
    except Exception as e:
        print(f"Unexpected error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Internal server error: {str(e)}'}),
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET,OPTIONS'
            }
        }