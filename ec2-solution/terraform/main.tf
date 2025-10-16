terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ==================== RANDOM RESOURCES ====================
# Random suffix for unique resource names
resource "random_id" "suffix" {
  byte_length = 4
}

# ==================== SECURITY GROUPS ====================
# Bastion Security Group (no dependencies)
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH from management subnet and GitHub Actions"

  # Allow SSH from management CIDR (for manual access)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.management_cidr]
    description = "SSH from management subnet"
  }

  # Note: GitHub Actions IPs will be added dynamically during deployment
  # No static GitHub Actions IP ranges needed here

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Resume Security Group (depends on bastion_sg)
resource "aws_security_group" "resume_sg" {
  name        = "resume-website-sg"
  description = "Allow web traffic and SSH from bastion"

  # Allow HTTP from anywhere (for direct access)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from anywhere (for future SSL)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH only from bastion (security maintained)
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==================== KEY PAIRS ====================
resource "aws_key_pair" "deployer" {
  key_name   = "${var.key_name}-${random_id.suffix.hex}"
  public_key = var.public_key_content != "" ? var.public_key_content : file(var.public_key_path)
}

# ==================== EC2 INSTANCES ====================
# EC2 Instances for Web Server (supports multiple instances)
resource "aws_instance" "webserver" {
  count                       = var.instance_count
  ami                         = "ami-0214c80a20a6f5239" # Amazon Linux 2 (eu-west-1)
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  security_groups             = [aws_security_group.resume_sg.name]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "ResumeWebsite-${count.index + 1}"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y python3 pip
              pip3 install flask boto3
              EOF
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami                    = var.bastion_ami_id
  instance_type          = var.bastion_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "BastionHost"
  }

  user_data = <<-EOF
              #!/bin/bash
              echo "Bastion host ready"
              EOF
}

# ==================== IAM RESOURCES ====================

# IAM Policy for GitHub Actions to manage security groups dynamically
resource "aws_iam_policy" "github_actions_sg_policy" {
  name = "github_actions_security_group_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DescribeSecurityGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_resume_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2 DynamoDB Policy for Flask Application
resource "aws_iam_policy" "ec2_dynamodb" {
  name = "ec2_dynamodb_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.visitor_count.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_dynamodb" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_dynamodb.arn
}

# EC2 SES Policy for Contact Form
resource "aws_iam_policy" "ec2_ses" {
  name = "ec2_ses_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ses" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_ses.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_resume_profile"
  role = aws_iam_role.ec2_role.name
}

# Visitor Counter Resources (same as before)
resource "aws_dynamodb_table" "visitor_count" {
  name         = "ec2_ResumeVisitorCount"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# SES for Contact Form
resource "aws_ses_domain_identity" "resume_domain" {
  domain = var.domain_name
}

# Lambda Functions
# Visitor Counter Lambda
resource "aws_lambda_function" "visitor_counter" {
  filename      = "visitor_counter_lambda.zip"
  function_name = "resume_visitor_counter_python"
  role          = aws_iam_role.lambda_role.arn
  handler       = "visitor_counter_lambda.lambda_handler"
  runtime       = "python3.9"
  timeout       = 10

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.visitor_count.name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_iam_role_policy_attachment.lambda_dynamodb,
    aws_cloudwatch_log_group.visitor_counter_logs,
  ]
}

# Contact Form Lambda
resource "aws_lambda_function" "contact_form" {
  filename      = "contact_form_lambda.zip"
  function_name = "resume_contact_form_python"
  role          = aws_iam_role.lambda_role.arn
  handler       = "contact_form_lambda.lambda_handler"
  runtime       = "python3.9"
  timeout       = 30

  environment {
    variables = {
      EMAIL_RECIPIENT = var.email_recipient
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_iam_role_policy_attachment.lambda_ses,
    aws_cloudwatch_log_group.contact_form_logs,
  ]
}

# Lambda IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "ec2_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda CloudWatch Logs Policy
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda DynamoDB Policy for Visitor Counter
resource "aws_iam_policy" "lambda_dynamodb" {
  name = "lambda_dynamodb_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.visitor_count.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb.arn
}

# Lambda SES Policy for Contact Form
resource "aws_iam_policy" "lambda_ses" {
  name = "lambda_ses_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ses" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_ses.arn
}

# CloudWatch Log Groups for Lambda Functions
resource "aws_cloudwatch_log_group" "visitor_counter_logs" {
  name              = "/aws/lambda/resume_visitor_counter_python"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "contact_form_logs" {
  name              = "/aws/lambda/resume_contact_form_python"
  retention_in_days = 14
}

# API Gateway for Lambda Functions
resource "aws_api_gateway_rest_api" "resume_api" {
  name        = "resume-website-python-api"
  description = "API for Resume Website Python Lambda Functions"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway Resources and Methods for Visitor Counter
resource "aws_api_gateway_resource" "visitor_counter_resource" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  parent_id   = aws_api_gateway_rest_api.resume_api.root_resource_id
  path_part   = "visitor-count"
}

resource "aws_api_gateway_method" "visitor_counter_method" {
  rest_api_id   = aws_api_gateway_rest_api.resume_api.id
  resource_id   = aws_api_gateway_resource.visitor_counter_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "visitor_counter_options" {
  rest_api_id   = aws_api_gateway_rest_api.resume_api.id
  resource_id   = aws_api_gateway_resource.visitor_counter_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# API Gateway Resources and Methods for Contact Form
resource "aws_api_gateway_resource" "contact_form_resource" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  parent_id   = aws_api_gateway_rest_api.resume_api.root_resource_id
  path_part   = "contact"
}

resource "aws_api_gateway_method" "contact_form_method" {
  rest_api_id   = aws_api_gateway_rest_api.resume_api.id
  resource_id   = aws_api_gateway_resource.contact_form_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "contact_form_options" {
  rest_api_id   = aws_api_gateway_rest_api.resume_api.id
  resource_id   = aws_api_gateway_resource.contact_form_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Lambda Integrations
resource "aws_api_gateway_integration" "visitor_counter_integration" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.visitor_counter_resource.id
  http_method = aws_api_gateway_method.visitor_counter_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.visitor_counter.invoke_arn
}

resource "aws_api_gateway_integration" "contact_form_integration" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.contact_form_resource.id
  http_method = aws_api_gateway_method.contact_form_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.contact_form.invoke_arn
}

# CORS Integration Responses
resource "aws_api_gateway_integration" "visitor_counter_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.visitor_counter_resource.id
  http_method = aws_api_gateway_method.visitor_counter_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_integration" "contact_form_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.contact_form_resource.id
  http_method = aws_api_gateway_method.contact_form_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

# Method Responses for CORS
resource "aws_api_gateway_method_response" "visitor_counter_response" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.visitor_counter_resource.id
  http_method = aws_api_gateway_method.visitor_counter_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "contact_form_response" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.contact_form_resource.id
  http_method = aws_api_gateway_method.contact_form_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "visitor_counter_options_response" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.visitor_counter_resource.id
  http_method = aws_api_gateway_method.visitor_counter_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "contact_form_options_response" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.contact_form_resource.id
  http_method = aws_api_gateway_method.contact_form_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Integration Responses for CORS
resource "aws_api_gateway_integration_response" "visitor_counter_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.visitor_counter_resource.id
  http_method = aws_api_gateway_method.visitor_counter_options.http_method
  status_code = aws_api_gateway_method_response.visitor_counter_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_integration_response" "contact_form_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  resource_id = aws_api_gateway_resource.contact_form_resource.id
  http_method = aws_api_gateway_method.contact_form_options.http_method
  status_code = aws_api_gateway_method_response.contact_form_options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Lambda Permissions for API Gateway
resource "aws_lambda_permission" "visitor_counter_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.resume_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "contact_form_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_form.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.resume_api.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "resume_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.visitor_counter_integration,
    aws_api_gateway_integration.contact_form_integration,
    aws_api_gateway_integration.visitor_counter_options_integration,
    aws_api_gateway_integration.contact_form_options_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.resume_api.id
  stage_name  = "prod"
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "resume_dashboard" {
  dashboard_name = "ResumeWebsiteDashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = concat(
            [for i in range(var.instance_count) : ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.webserver[i].id]],
            [for i in range(var.instance_count) : ["AWS/EC2", "NetworkIn", "InstanceId", aws_instance.webserver[i].id]],
            [for i in range(var.instance_count) : ["AWS/EC2", "NetworkOut", "InstanceId", aws_instance.webserver[i].id]]
          )
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 Instance Metrics"
        }
      }
    ]
  })
}

output "instance_public_ip" {
  value       = var.instance_count == 1 ? aws_instance.webserver[0].public_ip : null
  description = "Public IP of the first webserver instance (for backward compatibility)"
}

output "instance_public_dns" {
  value       = var.instance_count == 1 ? aws_instance.webserver[0].public_dns : null
  description = "Public DNS of the first webserver instance (for backward compatibility)"
}

output "instance_private_ip" {
  value       = var.instance_count == 1 ? aws_instance.webserver[0].private_ip : null
  description = "Private IP of the first webserver instance (for backward compatibility)"
}

output "webserver_instance_id" {
  value       = var.instance_count == 1 ? aws_instance.webserver[0].id : null
  description = "Instance ID of the first webserver (for backward compatibility)"
}

# New outputs for multiple instances
output "web_instance_public_ips" {
  value       = aws_instance.webserver[*].public_ip
  description = "List of all webserver public IPs"
}

output "web_instance_private_ips" {
  value       = aws_instance.webserver[*].private_ip
  description = "List of all webserver private IPs"
}

output "web_instance_public_dns" {
  value       = aws_instance.webserver[*].public_dns
  description = "List of all webserver public DNS names"
}

output "web_instance_ids" {
  value       = aws_instance.webserver[*].id
  description = "List of all webserver instance IDs"
}

output "instance_count" {
  value       = var.instance_count
  description = "Number of instances deployed"
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_security_group_id" {
  value       = aws_security_group.bastion_sg.id
  description = "Security Group ID for bastion host - used by GitHub Actions for dynamic IP whitelisting"
}

output "api_gateway_url" {
  value = "${aws_api_gateway_rest_api.resume_api.execution_arn}/prod"
}

output "visitor_counter_url" {
  value = "${aws_api_gateway_deployment.resume_api_deployment.invoke_url}/visitor-count"
}

output "contact_form_url" {
  value = "${aws_api_gateway_deployment.resume_api_deployment.invoke_url}/contact"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.visitor_count.name
}