"""
Unit tests for Python Lambda functions using pytest and unittest.mock.
These tests mock boto3 clients so no actual AWS calls are made.

Run with: python -m pytest __tests__/test_lambda_functions.py -v
"""

import json
import os
import pytest
from unittest.mock import Mock, patch, MagicMock

# Import the lambda functions
import sys
sys.path.append('..')
from visitor_counter_lambda import lambda_handler as visitor_counter_handler
from contact_form_lambda import lambda_handler as contact_form_handler


class TestVisitorCounterLambda:
    """Test cases for the visitor counter Lambda function"""
    
    def setup_method(self):
        """Setup test environment before each test"""
        os.environ['TABLE_NAME'] = 'TestTable'
    
    def teardown_method(self):
        """Clean up after each test"""
        if 'TABLE_NAME' in os.environ:
            del os.environ['TABLE_NAME']
    
    @patch('visitor_counter_lambda.boto3.resource')
    def test_increments_count_and_returns_200_with_new_count(self, mock_resource):
        """Test successful count increment"""
        # Setup DynamoDB mock
        mock_table = Mock()
        mock_table.get_item.return_value = {'Item': {'count': 5}}
        mock_table.put_item.return_value = {}
        mock_resource.return_value.Table.return_value = mock_table
        
        # Call the Lambda function
        event = {}
        context = {}
        response = visitor_counter_handler(event, context)
        
        # Verify response
        assert response['statusCode'] == 200
        body = json.loads(response['body'])
        assert body['count'] == 6
        assert response['headers']['Access-Control-Allow-Origin'] == '*'
        assert 'Access-Control-Allow-Headers' in response['headers']
        assert 'Access-Control-Allow-Methods' in response['headers']
        
        # Verify DynamoDB calls
        mock_table.get_item.assert_called_once_with(Key={'id': 'resume'})
        mock_table.put_item.assert_called_once_with(
            Item={'id': 'resume', 'count': 6}
        )
    
    @patch('visitor_counter_lambda.boto3.resource')
    def test_handles_new_item_creation(self, mock_resource):
        """Test creating new count when item doesn't exist"""
        # Setup DynamoDB mock with no existing item
        mock_table = Mock()
        mock_table.get_item.return_value = {}  # No 'Item' key means item doesn't exist
        mock_table.put_item.return_value = {}
        mock_resource.return_value.Table.return_value = mock_table
        
        # Call the Lambda function
        event = {}
        context = {}
        response = visitor_counter_handler(event, context)
        
        # Verify response - should start with count 1
        assert response['statusCode'] == 200
        body = json.loads(response['body'])
        assert body['count'] == 1
        assert response['headers']['Access-Control-Allow-Origin'] == '*'
        
        # Verify DynamoDB calls
        mock_table.put_item.assert_called_once_with(
            Item={'id': 'resume', 'count': 1}
        )
    
    @patch('visitor_counter_lambda.boto3.resource')
    def test_handles_dynamodb_error_and_returns_500(self, mock_resource):
        """Test DynamoDB error handling"""
        # Setup mock to raise exception
        from botocore.exceptions import ClientError
        mock_table = Mock()
        mock_table.get_item.side_effect = ClientError(
            {'Error': {'Code': 'ValidationException', 'Message': 'boom'}},
            'GetItem'
        )
        mock_resource.return_value.Table.return_value = mock_table
        
        # Call the Lambda function
        event = {}
        context = {}
        response = visitor_counter_handler(event, context)
        
        # Verify error response
        assert response['statusCode'] == 500
        body = json.loads(response['body'])
        assert 'error' in body
        assert 'Database error' in body['error']
        assert response['headers']['Access-Control-Allow-Origin'] == '*'


class TestContactFormLambda:
    """Test cases for the contact form Lambda function"""
    
    def setup_method(self):
        """Setup test environment before each test"""
        os.environ['EMAIL_RECIPIENT'] = 'test@example.com'
    
    def teardown_method(self):
        """Clean up after each test"""
        if 'EMAIL_RECIPIENT' in os.environ:
            del os.environ['EMAIL_RECIPIENT']
    
    @patch('contact_form_lambda.boto3.client')
    def test_sends_email_and_returns_200(self, mock_client):
        """Test successful email sending"""
        # Setup SES mock
        mock_ses = Mock()
        mock_ses.send_email.return_value = {'MessageId': '123456789'}
        mock_client.return_value = mock_ses
        
        # Prepare event
        event = {
            'body': json.dumps({
                'name': 'John Doe',
                'email': 'john@example.com',
                'message': 'Hello, this is a test message!'
            })
        }
        context = {}
        
        # Call the Lambda function
        response = contact_form_handler(event, context)
        
        # Verify response
        assert response['statusCode'] == 200
        body = json.loads(response['body'])
        assert 'Email sent successfully' in body['message']
        assert body['recipient'] == 'test@example.com'
        assert response['headers']['Access-Control-Allow-Origin'] == '*'
        assert 'Access-Control-Allow-Headers' in response['headers']
        assert 'Access-Control-Allow-Methods' in response['headers']
        
        # Verify SES call
        mock_ses.send_email.assert_called_once()
        call_args = mock_ses.send_email.call_args[1]
        assert call_args['Source'] == 'test@example.com'
        assert 'john@example.com' in call_args['Message']['Body']['Text']['Data']
    
    def test_handles_missing_fields_and_returns_400(self):
        """Test validation of required fields"""
        # Prepare event with missing fields
        event = {
            'body': json.dumps({
                'name': 'John Doe',
                'email': '',  # Missing email
                'message': 'Hello!'
            })
        }
        context = {}
        
        # Call the Lambda function
        response = contact_form_handler(event, context)
        
        # Verify validation error
        assert response['statusCode'] == 400
        body = json.loads(response['body'])
        assert 'All fields' in body['error']
        assert 'required' in body['error']
        assert response['headers']['Access-Control-Allow-Origin'] == '*'
    
    def test_handles_invalid_json_and_returns_400(self):
        """Test invalid JSON handling"""
        # Prepare event with invalid JSON
        event = {
            'body': 'invalid json {'
        }
        context = {}
        
        # Call the Lambda function
        response = contact_form_handler(event, context)
        
        # Verify JSON error
        assert response['statusCode'] == 400
        body = json.loads(response['body'])
        assert 'Invalid JSON' in body['error']
        assert response['headers']['Access-Control-Allow-Origin'] == '*'
    
    @patch('contact_form_lambda.boto3.client')
    def test_handles_ses_error_and_returns_500(self, mock_client):
        """Test SES error handling"""
        # Setup mock to raise SES exception
        from botocore.exceptions import ClientError
        mock_ses = Mock()
        mock_ses.send_email.side_effect = ClientError(
            {'Error': {'Code': 'MessageRejected', 'Message': 'Email not verified'}},
            'SendEmail'
        )
        mock_client.return_value = mock_ses
        
        # Prepare valid event
        event = {
            'body': json.dumps({
                'name': 'John Doe',
                'email': 'john@example.com',
                'message': 'Hello, this is a test message!'
            })
        }
        context = {}
        
        # Call the Lambda function
        response = contact_form_handler(event, context)
        
        # Verify error response
        assert response['statusCode'] == 500
        body = json.loads(response['body'])
        assert 'Email address not verified' in body['error']
        assert response['headers']['Access-Control-Allow-Origin'] == '*'
    
    @patch('contact_form_lambda.boto3.client')
    def test_handles_unexpected_error_and_returns_500(self, mock_client):
        """Test unexpected error handling"""
        # Setup mock to raise unexpected exception
        mock_ses = Mock()
        mock_ses.send_email.side_effect = Exception('Unexpected error')
        mock_client.return_value = mock_ses
        
        # Prepare valid event
        event = {
            'body': json.dumps({
                'name': 'John Doe',
                'email': 'john@example.com',
                'message': 'Hello, this is a test message!'
            })
        }
        context = {}
        
        # Call the Lambda function
        response = contact_form_handler(event, context)
        
        # Verify error response
        assert response['statusCode'] == 500
        body = json.loads(response['body'])
        assert 'Internal server error' in body['error']
        assert response['headers']['Access-Control-Allow-Origin'] == '*'


if __name__ == '__main__':
    # Run tests if script is executed directly
    import subprocess
    import sys
    
    print("Running Python Lambda tests...")
    result = subprocess.run([
        sys.executable, '-m', 'pytest', __file__, '-v'
    ], capture_output=True, text=True)
    
    print(result.stdout)
    if result.stderr:
        print("STDERR:", result.stderr)
    
    exit(result.returncode)