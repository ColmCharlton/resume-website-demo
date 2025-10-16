#!/bin/bash
# Test runner script for Python Lambda functions

echo "Setting up test environment..."

# Install test dependencies
pip install -r requirements-test.txt

echo "Running Python Lambda tests..."

# Run tests with coverage
pytest __tests__/test_lambda_functions.py -v --tb=short

echo "Test run complete!"