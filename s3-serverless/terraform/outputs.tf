output "s3_bucket_name" {
  value = aws_s3_bucket.resume_website.id
}

output "lambda_contact_arn" {
  value = aws_lambda_function.contact_form.arn
}

# output "ses_verification_status" {
#   value = aws_ses_email_identity.contact.verification_status
# }

output "website_url" {
  description = "The CloudFront distribution domain name for the website"
  value       = aws_cloudfront_distribution.resume_distribution.domain_name
}

output "api_base_url" {
  description = "The base API Gateway invoke URL"
  value       = aws_api_gateway_deployment.resume_api_deployment.invoke_url
}

output "s3_website_endpoint" {
  description = "The S3 static website endpoint"
  value       = aws_s3_bucket.resume_website.website_endpoint
}