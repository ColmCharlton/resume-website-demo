variable "aws_region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "eu-west-1"
}
variable "project_name" {
  description = "Project name for tagging and resource naming."
  type        = string
  default     = "ResumeWebsite"
}

variable "environment" {
  description = "Deployment environment (e.g., Production, Staging)."
  type        = string
  default     = "Production"
}

variable "access_logs_purpose" {
  description = "Purpose tag for access logs bucket."
  type        = string
  default     = "AccessLogs"
}

variable "lambda_runtime" {
  description = "Lambda runtime version."
  type        = string
  default     = "nodejs18.x"
}
# variable "ses_identity_arn" {
#   description = "The ARN of the SES identity (email or domain) to allow Lambda to send emails from."
#   type        = string
# }
variable "contact_email" {
  description = "Contact form recipient email"
  type        = string
}

# variable "domain_name" {
#   description = "Website domain name"
#   type        = string
# }

variable "github_repo" {
  description = "GitHub repository for CI/CD"
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner for CI/CD"
  type        = string
}

variable "github_branch" {
  description = "GitHub repository branch for CI/CD"
  type        = string
}

variable "github_token" {
  description = "GitHub token for CI/CD"
  type        = string
  sensitive   = true
}