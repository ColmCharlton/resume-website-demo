# Python Lambda Functions Tests

This directory contains comprehensive unit tests for the Python Lambda functions using pytest and moto for AWS service mocking.

## Test Structure

```
lambda/
├── __tests__/
│   └── test_lambda_functions.py    # Main test file
├── visitor_counter_lambda.py       # Lambda function
├── contact_form_lambda.py          # Lambda function
├── requirements-test.txt           # Test dependencies
├── pytest.ini                     # Pytest configuration
├── run_tests.sh                   # Bash test runner
├── run_tests.ps1                  # PowerShell test runner
└── README.md                      # This file
```

## Test Coverage

### Visitor Counter Lambda Tests
- ✅ Successful count increment from existing value
- ✅ New item creation when count doesn't exist
- ✅ DynamoDB error handling
- ✅ CORS headers validation
- ✅ Response format validation

### Contact Form Lambda Tests
- ✅ Successful email sending via SES
- ✅ Input validation (missing fields)
- ✅ Invalid JSON handling
- ✅ SES error handling (MessageRejected, etc.)
- ✅ Unexpected error handling
- ✅ CORS headers validation

## Running Tests

### Prerequisites
```bash
pip install -r requirements-test.txt
```

### Run Tests

**Option 1: Using test runner scripts**
```bash
# Linux/Mac
./run_tests.sh

# Windows PowerShell
.\run_tests.ps1
```

**Option 2: Direct pytest**
```bash
# Run all tests
pytest __tests__/test_lambda_functions.py -v

# Run specific test class
pytest __tests__/test_lambda_functions.py::TestVisitorCounterLambda -v

# Run specific test
pytest __tests__/test_lambda_functions.py::TestVisitorCounterLambda::test_increments_count_and_returns_200_with_new_count -v
```

## Test Dependencies

- **pytest**: Test framework
- **moto**: AWS service mocking (DynamoDB, SES)
- **boto3**: AWS SDK for Python
- **botocore**: Core functionality for boto3

## Comparison with JavaScript Tests

| Feature | JavaScript (Jest) | Python (pytest) |
|---------|------------------|------------------|
| Test Framework | Jest | pytest |
| AWS Mocking | Manual jest.doMock | moto library |
| Test Structure | describe/test blocks | Class-based with methods |
| Assertions | expect() | assert statements |
| Setup/Teardown | beforeEach() | setup_method()/teardown_method() |

## Test Philosophy

Both test suites follow the same testing principles:
1. **Unit tests only** - No actual AWS calls
2. **Comprehensive coverage** - Success and error cases
3. **CORS validation** - Ensure proper headers
4. **Input validation** - Test edge cases
5. **Error handling** - Test various failure scenarios

This provides excellent examples of testing serverless functions in both JavaScript and Python ecosystems.