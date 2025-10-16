terraform {
  backend "s3" {
    bucket = "terraform-state-resume-website"
    key    = "ec2-solution/terraform.tfstate"
    region = "eu-west-1"

    # DynamoDB table for state locking
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}