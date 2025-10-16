import json
import boto3
import os
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    """
    Lambda function to handle contact form submissions for resume website.
    This function sends an email using AWS SES when a contact form is submitted.
    
    Args:
        event: Lambda event containing the form data in the body
        context: Lambda context object
        
    Returns:
        dict: Response with statusCode, body, and CORS headers
    """
    
    try:
        # Parse the request body
        if isinstance(event.get('body'), str):
            body = json.loads(event['body'])
        else:
            body = event.get('body', {})
            
        # Extract form data
        name = body.get('name', '').strip()
        email = body.get('email', '').strip()
        message = body.get('message', '').strip()
        
        # Validate required fields
        if not all([name, email, message]):
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'All fields (name, email, message) are required'}),
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type',
                    'Access-Control-Allow-Methods': 'POST,OPTIONS'
                }
            }
        
        # Get recipient email from environment variable or use default
        recipient_email = os.environ.get('EMAIL_RECIPIENT', 'columcharlton@gmail.com')
        
        # Initialize SES client
        ses_client = boto3.client('ses')
        
        # Construct email subject and body (matching S3 Lambda exactly)
        subject = "New Contact Form Submission"
        email_body = f"Name: {name}\nEmail: {email}\nMessage: {message}"
        
        # Send email using SES
        response = ses_client.send_email(
            Source=recipient_email,  # Must be a verified email in SES
            Destination={
                'ToAddresses': [recipient_email]
            },
            Message={
                'Subject': {
                    'Data': subject,
                    'Charset': 'UTF-8'
                },
                'Body': {
                    'Text': {
                        'Data': email_body,
                        'Charset': 'UTF-8'
                    }
                }
            }
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Email sent successfully',
                'recipient': recipient_email
            }),
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST,OPTIONS'
            }
        }
        
    except json.JSONDecodeError:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid JSON in request body'}),
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST,OPTIONS'
            }
        }
    except ClientError as e:
        error_code = e.response['Error']['Code']
        print(f"SES error: {e}")
        
        if error_code == 'MessageRejected':
            error_message = 'Email address not verified or message rejected'
        elif error_code == 'SendingPausedException':
            error_message = 'Email sending is paused for this account'
        else:
            error_message = f'Email service error: {error_code}'
            
        return {
            'statusCode': 500,
            'body': json.dumps({'error': error_message}),
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST,OPTIONS'
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
                'Access-Control-Allow-Methods': 'POST,OPTIONS'
            }
        }