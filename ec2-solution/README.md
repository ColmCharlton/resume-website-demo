# EC2-Based Resume Website

This project is an EC2-based resume website that utilizes a Flask application hosted on an AWS EC2 instance. It incorporates a CI/CD pipeline using GitHub Actions, along with various AWS services for enhanced functionality.

## Project Structure

```
resume-website-ec2
├── app
│   ├── __init__.py
│   ├── routes.py
│   ├── templates
│   │   ├── index.html
│   │   └── base.html
│   ├── static
│   │   ├── css
│   │   ├── js
│   │   └── images
│   └── services
│       ├── visitor_counter.py
│       └── email_service.py
├── config.py
├── requirements.txt
├── wsgi.py
├── lambda
│   ├── visitor_counter_lambda.py
│   └── contact_form_lambda.py
├── terraform
│   └── main.tf
├── ansible
│   ├── playbook.yml
│   └── templates
│       ├── nginx.conf.j2
│       ├── supervisor.conf.j2
│       └── cloudwatch-config.json.j2
├── .github
│   └── workflows
│       └── deploy.yml
└── README.md
```

## Features

- **Visitor Counter**: Tracks the number of visitors using AWS DynamoDB.
- **Contact Form**: Allows users to send messages via email using AWS SES.
- **Analytics**: Monitors application performance with AWS CloudWatch.
- **Infrastructure as Code**: Uses Terraform for provisioning AWS resources.
- **Configuration Management**: Utilizes Ansible for setting up the EC2 instance.
- **CI/CD Pipeline**: Automates deployment with GitHub Actions.
- **Multi-Instance Support**: Supports deploying multiple EC2 instances for high availability.

## Deployment Options

### Single Instance Deployment (Default)
The default configuration deploys a single EC2 instance suitable for development and small-scale production use.

### Multi-Instance Deployment
For high availability and load distribution, you can deploy multiple EC2 instances by setting the `instance_count` variable in your Terraform configuration.

```hcl
# In terraform.tfvars
instance_count = 3  # Deploy 3 EC2 instances
```

The CI/CD pipeline automatically detects and configures all instances using Ansible.

## Setup Instructions

1. **Clone the Repository**:
   ```
   git clone https://github.com/yourusername/resume-website-ec2.git
   cd resume-website-ec2
   ```

2. **Install Dependencies**:
   Ensure you have Python 3 and pip installed. Then, install the required packages:
   ```
   pip install -r requirements.txt
   ```

3. **Configure AWS Credentials**:
   Set up your AWS credentials in the `config.py` file.

4. **Provision Infrastructure**:
   Navigate to the `terraform` directory and run:
   ```
   terraform init
   terraform apply
   ```

5. **Deploy Application**:
   Use the Ansible playbook to configure the EC2 instance:
   ```
   ansible-playbook -i "your_ec2_public_ip," ansible/playbook.yml --user ubuntu --private-key your_private_key.pem
   ```

6. **Access the Website**:
   Open your web browser and navigate to `http://your_ec2_public_ip` to view your resume website.

## Usage

- The main page displays the visitor count and a contact form.
- The visitor count is updated in real-time.
- Submitted contact forms are sent to your specified email address.

## Monitoring and Maintenance

- Use AWS CloudWatch to monitor application metrics.
- Regularly check logs for any errors or issues.
- Update dependencies and infrastructure as needed.

## License

This project is licensed under the MIT License. See the LICENSE file for details.



Prerequisites
AWS account with appropriate permissions
Terraform installed
Ansible installed
AWS CLI configured with credentials

SSH key pair for EC2 access - 
Option 1: Generate New SSH Key Pair
# 1. Create .ssh directory if it doesn't exist
if (!(Test-Path "$env:USERPROFILE\.ssh")) {
    New-Item -ItemType Directory -Path "$env:USERPROFILE\.ssh"
}

# 2. Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f "$env:USERPROFILE\.ssh\id_rsa" -N '""'

# 3. Verify keys were created
Get-ChildItem "$env:USERPROFILE\.ssh\id_rsa*"

Option 2: Use Existing SSH Keys
# Check if keys exist
Get-ChildItem "$env:USERPROFILE\.ssh\id_rsa*"

# If they exist, you're ready to go
# If not, follow Option 1 above


Local Development
# 1. Clone and navigate to project
cd "c:\Users\colum\OneDrive\CV\Cv_Website\ec2-solution"

# 2. Create virtual environment
python -m venv myenvec2
.\myenvec2\Scripts\Activate.ps1

# 3. Install dependencies
pip install -r requirements.txt

# 4. Set environment variables
$env:SECRET_KEY = "your_secret_key"
$env:AWS_ACCESS_KEY_ID = "your_access_key"
$env:AWS_SECRET_ACCESS_KEY = "your_secret_key"
$env:AWS_REGION = "eu-west-1"
$env:DYNAMODB_TABLE = "ResumeVisitorCount"
$env:SES_EMAIL = "your_verified_email@domain.com"

# 5. Run locally (development mode)
python wsgi.py
