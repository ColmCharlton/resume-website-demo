# PowerShell script to package Lambda functions for Terraform deployment
# Run this script from the terraform directory

Write-Host "Packaging Lambda functions..." -ForegroundColor Green

# Set the path to the lambda directory
$lambdaDir = "..\lambda"
$terraformDir = "."

# Package visitor counter lambda
Write-Host "Packaging visitor counter lambda..." -ForegroundColor Yellow
Compress-Archive -Path "$lambdaDir\visitor_counter_lambda.py" -DestinationPath "$terraformDir\visitor_counter_lambda.zip" -Force

# Package contact form lambda
Write-Host "Packaging contact form lambda..." -ForegroundColor Yellow  
Compress-Archive -Path "$lambdaDir\contact_form_lambda.py" -DestinationPath "$terraformDir\contact_form_lambda.zip" -Force

Write-Host "Lambda packages created successfully!" -ForegroundColor Green
Write-Host "Files created:" -ForegroundColor White
Write-Host "- visitor_counter_lambda.zip" -ForegroundColor Cyan
Write-Host "- contact_form_lambda.zip" -ForegroundColor Cyan