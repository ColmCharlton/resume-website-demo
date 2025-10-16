variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "public_key_path" {
  description = "Path to public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "public_key_content" {
  description = "Content of the public key"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain name for SES/ACM"
  type        = string
}

variable "management_cidr" {
  description = "CIDR block for management SSH access"
  type        = string
}

variable "bastion_ami_id" {
  description = "AMI ID for bastion host"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t2.micro"
}

variable "email_recipient" {
  description = "Email address to receive contact form submissions"
  type        = string
  default     = "columcharlton@gmail.com"
}

variable "instance_count" {
  description = "Number of EC2 instances to deploy"
  type        = number
  default     = 1
}
