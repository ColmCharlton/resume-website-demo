# PowerShell test runner script for Python Lambda functions

Write-Host "Setting up test environment..." -ForegroundColor Green

# Install test dependencies
Write-Host "Installing test dependencies..." -ForegroundColor Yellow
pip install -r requirements-test.txt

Write-Host "Running Python Lambda tests..." -ForegroundColor Green

# Run tests with coverage
pytest __tests__/test_lambda_functions.py -v --tb=short

Write-Host "Test run complete!" -ForegroundColor Green