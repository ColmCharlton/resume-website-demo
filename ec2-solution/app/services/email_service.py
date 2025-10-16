import boto3
import os
from botocore.exceptions import ClientError

def send_contact_email(name, email, message):
    """
    Send contact form email using AWS SES.
    This matches the S3 Lambda implementation functionality.
    
    Args:
        name (str): Name of the person submitting the form
        email (str): Email address of the person submitting the form
        message (str): The message content
        
    Returns:
        dict: SES response with MessageId
        
    Raises:
        Exception: If there's an error sending the email
    """
    
    # Validate required fields
    if not all([name, email, message]):
        raise ValueError('All fields (name, email, message) are required')
    
    # Strip whitespace
    name = name.strip()
    email = email.strip()
    message = message.strip()
    
    try:
        # Get recipient email from environment variable or use default
        recipient_email = os.environ.get('EMAIL_RECIPIENT', 'columcharlton@gmail.com')
        
        # Get AWS region from multiple sources, with fallbacks
        region = (
            os.environ.get('AWS_REGION') or 
            os.environ.get('AWS_DEFAULT_REGION') or
            'eu-west-1'
        )
        
        print(f"DEBUG: Using AWS region: {region}")
        print(f"DEBUG: Environment AWS_REGION: {os.environ.get('AWS_REGION', 'NOT_SET')}")
        print(f"DEBUG: Environment AWS_DEFAULT_REGION: {os.environ.get('AWS_DEFAULT_REGION', 'NOT_SET')}")
        
        # Initialize SES client - let it use IAM role credentials automatically
        # Don't pass explicit credentials, let boto3 use the instance profile
        ses_client = boto3.client('ses', region_name=region)
        
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
        
        return response
        
    except ClientError as e:
        error_code = e.response['Error']['Code']
        print(f"SES error: {e}")
        
        if error_code == 'MessageRejected':
            error_message = 'Email address not verified or message rejected'
        elif error_code == 'SendingPausedException':
            error_message = 'Email sending is paused for this account'
        else:
            error_message = f'Email service error: {error_code}'
            
        raise Exception(error_message)
        
    except Exception as e:
        print(f"Unexpected error: {e}")
        raise Exception(f"Internal server error: {str(e)}")