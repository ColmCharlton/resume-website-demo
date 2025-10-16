# Terraform Setup for Resume Website

This directory contains the Terraform configuration files necessary to set up the AWS infrastructure for the comprehensive resume website project.

## Prerequisites

- Ensure you have [Terraform](https://www.terraform.io/downloads.html) installed on your machine.
- Configure your AWS credentials using the AWS CLI or by setting environment variables.

## Getting Started

1. **Initialize Terraform**: This command initializes the Terraform configuration and downloads the necessary provider plugins.
   ```
   terraform init
   ```

2. **Plan the Infrastructure**: This command creates an execution plan, showing what actions Terraform will take to change the infrastructure.
   ```
   terraform plan
   ```

3. **Apply the Configuration**: This command applies the changes required to reach the desired state of the configuration.
   ```
   terraform apply
   ```

4. **Destroy the Infrastructure**: If you need to tear down the infrastructure, use the following command:
   ```
   terraform destroy
   ```

## Directory Structure

- `main.tf`: Main Terraform configuration for AWS resources including S3, CloudFront, DynamoDB, Lambda, API Gateway, SES, CloudWatch, and CodePipeline.
- `variables.tf`: Input variables for customizing the deployment (e.g., contact email, domain name, GitHub repo).
- `outputs.tf`: Key outputs such as S3 bucket name, Lambda ARNs, SES verification status, CloudFront URL, and API endpoint.
- `README.md`: This documentation.

## Infrastructure Overview

This configuration provisions:

- **S3 Bucket** for static website hosting.
- **CloudFront Distribution** for CDN and HTTPS.
- **DynamoDB Table** for visitor counting.
- **Lambda Functions** for visitor counting and contact form handling.
- **API Gateway** for backend API endpoints.
- **SES** for email identity verification.
- **CloudWatch Dashboard** for monitoring.
- **CodePipeline** for CI/CD integration with GitHub.
- **Kinesis Data Stream** for CloudFront real-time logging (CloudWatch Logs is not supported for real-time logs via Terraform).

## CloudFront Logging Notes

- **S3 Logging**: Not supported in new AWS accounts with ObjectOwnership=BucketOwnerEnforced. The S3 bucket for CloudFront logs is commented out in `main.tf`.
- **Real-time Logging**: Configured to use a Kinesis Data Stream. Only supported fields are included in the log config. See `main.tf` for details.
- **Unsupported Fields**: Only use fields supported by AWS for real-time logging. See AWS documentation for the latest list.

## Notes

- Review `variables.tf` and `main.tf` for any specific configurations or variables that may need to be adjusted for your environment.
- After applying the Terraform configuration, deploy the Lambda function code and set up the frontend as described in their respective documentation.
- Ensure you provide required variable values (e.g., contact email, domain name, GitHub repo) when running Terraform.