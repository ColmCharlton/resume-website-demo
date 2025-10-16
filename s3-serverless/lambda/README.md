# Lambda Functions Documentation

This directory contains the AWS Lambda functions used in the resume website project. 

## Functions Overview

1. **Visitor Counter**:
   - **Path**: `visitor-counter/index.js`
   - **Purpose**: This function increments and retrieves the visitor count from a DynamoDB table. It is triggered via an API Gateway endpoint.

2. **Contact Form**:
   - **Path**: `contact-form/index.js`
   - **Purpose**: This function handles submissions from the contact form. It sends an email using AWS SES with the details provided in the form.

## Deployment

To deploy the Lambda functions, ensure that the deployment packages are created and uploaded to the specified S3 bucket. The functions can be deployed using the Ansible playbook located in the `ansible` directory.

## Environment Variables

- **Visitor Counter**:
  - `TABLE_NAME`: The name of the DynamoDB table used to store visitor counts.

- **Contact Form**:
  - `EMAIL_RECIPIENT`: The email address where contact form submissions will be sent.