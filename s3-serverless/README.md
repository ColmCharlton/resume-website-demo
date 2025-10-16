# Resume Website – Serverless AWS Solution

This project delivers a modern, production-grade resume website using a fully serverless AWS architecture. It combines static hosting, dynamic backend features, advanced monitoring, and automated deployment workflows.

## Key Features

- **Static Frontend**: Hosted on S3, distributed globally via CloudFront.
- **Visitor Counter**: Real-time tracking using Lambda (Node.js), DynamoDB, and custom CloudWatch metrics.
- **Contact Form**: Serverless form with Lambda (Node.js), SES for email, and X-Ray tracing.
- **Advanced Logging & Monitoring**:
  - AWS X-Ray tracing for all Lambda functions
  - Custom CloudWatch metrics (e.g., contact form errors, visitor count)
  - CloudWatch Alarms for error rates, latency, and Lambda health
  - CloudWatch Dashboard for at-a-glance health
  - Log retention and SNS alerting for critical events
- **Access Logging**:
  - **API Gateway**: Access logs enabled
  - **CloudFront**: Real-time logging to Kinesis Data Stream (CloudWatch Logs is not supported for real-time logs via Terraform)
  - **S3**: Access logs for the main website bucket (CloudFront S3 logging is disabled due to AWS restrictions)
- **Infrastructure as Code**: All AWS resources provisioned via Terraform, including:
      - S3 (static site hosting, access logs)
      - Lambda (Node.js functions for backend logic)
      - DynamoDB (visitor counter storage)
      - SES (email sending for contact form)
      - CloudFront (CDN distribution, real-time logs via Kinesis)
      - API Gateway (REST endpoints for Lambdas)
      - IAM (roles, policies, least-privilege access)
      - CloudWatch (logs, custom metrics, alarms, dashboards)
      - SNS (alerting for CloudWatch alarms)
      - SSM Parameter Store (for configuration/secrets)
      - Log Groups (with retention policies)
      - Kinesis Data Stream (for CloudFront real-time logs)
      - All supporting networking, permissions, and monitoring resources
- **Automated Lambda Packaging**: Ansible playbook and PowerShell script automate npm install and zipping for Lambda deployment.
- **CI/CD Ready**: Buildspec files and workflow support for CodePipeline/CodeBuild integration.


## Architecture Overview

```
┌────────────┐      ┌──────────────┐      ┌────────────┐
│  Browser   │◀───▶│ CloudFront   │◀───▶│    S3      │
└─────┬──────┘      └─────┬────────┘      └────────────┘
      │                   │
      ▼                   ▼
┌────────────┐      ┌──────────────┐
│ API GW     │◀───▶│ Lambda       │
└─────┬──────┘      └─────┬────────┘
      │                   │
      ▼                   ▼
┌────────────┐      ┌──────────────┐      ┌──────────────┐
│ DynamoDB   │      │ SES (Email)  │      │ SSM Param   │
│ (Visitor   │      │ (Contact     │      │ Store        │
│ Counter)   │      │  Form Email) │      │ (Secrets)    │
└────────────┘      └──────────────┘      └──────────────┘
      │                   │
      ▼                   ▼
┌────────────┐      ┌──────────────┐
│ CloudWatch │◀───▶│ SNS Alerts   │
│ (Logs,     │      │ (Alarms)     │
│ Metrics,   │      └──────────────┘
│ Alarms,    │
│ Dashboard) │
└────────────┘

Supporting Components:
- IAM: Roles and policies for least-privilege access
- X-Ray: Tracing for all Lambda invocations
- Access Logging: S3, CloudFront (real-time via Kinesis), API Gateway
- CI/CD: CodePipeline & CodeBuild for automated build, test, and deploy
- Automation: Terraform (infrastructure), Ansible (Lambda packaging), PowerShell (local deploy)
- Kinesis: Real-time log stream for CloudFront
```

## Project Structure

```
resume-website-s3/
├── ansible/
│   ├── repackage-lambdas.yml         # Automates npm install & zip for Lambdas
│   ├── playbook.yml                  # (if present) for other config management
│   └── templates/
│       └── cloudwatch-config.json.j2 # Example Ansible template
├── frontend/
│   ├── index.html.tpl                # Main HTML template
│   ├── scripts.js                    # Frontend JS
│   └── styles.css                    # Frontend CSS
├── lambda/
│   ├── contact-form/
│   │   ├── index.js                  # Lambda handler for contact form
│   │   └── package.json              # Node.js dependencies
│   ├── visitor-counter/
│   │   ├── index.js                  # Lambda handler for visitor counter
│   │   └── package.json              # Node.js dependencies
│   ├── __tests__/
│   │   └── lambda.test.js            # Jest unit tests for Lambdas
│   ├── package.json                  # Shared dev dependencies (if any)
│   └── README.md                     # Lambda function docs
├── terraform/
│   ├── main.tf                       # Main Terraform config
│   ├── outputs.tf                    # Terraform outputs
│   ├── variables.tf                  # Terraform variables
│   ├── terraform.tfvars              # Variable values
│   ├── terraform.tfstate             # State file (not committed)
│   ├── terraform.tfstate.backup      # State backup (not committed)
│   ├── tfplan                        # Terraform plan output
│   └── README.md                     # Infra documentation
├── deploy.ps1                        # PowerShell script: package, apply, git push
├── buildspec.build.yml               # CodeBuild: build frontend, inject API URL
├── buildspec.deploy.yml              # CodeBuild: upload to S3
├── buildspec.invalidate.yml          # CodeBuild: CloudFront cache invalidation
├── buildspec.test.yaml               # CodeBuild: Lambda unit tests
└── README.md                         # Project documentation
```

## Deployment & Automation Workflow

### Local Workflow
1. **Package Lambdas**: Run Ansible playbook or `package-lambdas.ps1` to automate npm install and zipping for all Lambda functions.
2. **Terraform**: Apply infrastructure changes (`terraform init && terraform apply`).
3. **Git**: Commit and push changes to trigger CI/CD pipeline.

### CI/CD Pipeline (CodePipeline/CodeBuild)
- **Build**: Installs dependencies, builds frontend, packages Lambdas (npm/zip or Ansible), runs tests.
- **Deploy**: Uploads frontend to S3, deploys Lambda zips, invalidates CloudFront cache.
- **Test**: Runs Lambda unit tests and integration checks.

## Monitoring & Observability

- **X-Ray**: Distributed tracing for all Lambda invocations.
- **CloudWatch**: Logs, custom metrics, alarms, dashboards.
- **SNS**: Alerting for critical CloudWatch alarms.
- **Access Logs**: S3, CloudFront, API Gateway.

## Security & Best Practices

- IAM policies scoped to least privilege for all resources.
- Log retention and monitoring for compliance.
- All secrets managed via AWS Secrets Manager or SSM Parameter Store.

## CloudFront Logging Notes

- **S3 Logging**: Not supported in new AWS accounts with ObjectOwnership=BucketOwnerEnforced. The S3 bucket for CloudFront logs is commented out in `main.tf`.
- **Real-time Logging**: Configured to use a Kinesis Data Stream. Only supported fields are included in the log config. See `main.tf` for details.
- **Unsupported Fields**: Only use fields supported by AWS for real-time logging. See AWS documentation for the latest list.

## Maintenance

- Monitor CloudWatch dashboards and alarms for health.
- Review SES and DynamoDB metrics for usage and limits.
- Update dependencies and Lambda code as needed.

---

This project provides a robust, scalable, and observable serverless resume website, following AWS and DevOps best practices.