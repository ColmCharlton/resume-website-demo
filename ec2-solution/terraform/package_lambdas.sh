#!/bin/bash

# Script to package Lambda functions for Terraform deployment
# Run this script from the terraform directory

echo "Packaging Lambda functions..."

# Package visitor counter lambda
cd ../lambda
zip -r ../terraform/visitor_counter_lambda.zip visitor_counter_lambda.py

# Package contact form lambda  
zip -r ../terraform/contact_form_lambda.zip contact_form_lambda.py

echo "Lambda packages created successfully!"
echo "Files created:"
echo "- visitor_counter_lambda.zip"
echo "- contact_form_lambda.zip"

cd ../terraform