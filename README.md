# Resume Website - Multi-Solution Repository

## Overview
This repository contains multiple deployment solutions for a professional resume website, demonstrating different cloud architecture patterns and deployment strategies.

## 🏗️ Solutions

### 1. S3 Serverless (`s3-serverless/`)
**Serverless architecture with S3 + CloudFront**
- ⚡ **Ultra-low cost** (~$1-5/month)
- 🚀 **Global CDN** distribution
- 🔧 **AWS CodePipeline** deployment
- 📦 **Lambda functions** for dynamic content

### 2. EC2 Solution (`ec2-solution/`)
**Traditional server deployment with EC2**
- 🖥️ **Full server control** with EC2 instances
- 🔒 **Bastion host security** architecture
- 🤖 **Ansible automation** for configuration
- 🛠️ **GitHub Actions** CI/CD pipeline

### 3. EKS Containerized (`eks-containerized/`)
**Kubernetes orchestration (Coming Soon)**
- 🐳 **Docker containers** for portability
- ☸️ **Kubernetes** orchestration
- 📈 **Auto-scaling** capabilities
- 🔍 **Advanced monitoring** with Prometheus

## 🚀 Quick Start

Each solution has its own README with detailed deployment instructions:

- [`s3-serverless/README.md`](s3-serverless/README.md) - Serverless deployment guide
- [`ec2-solution/README.md`](ec2-solution/README.md) - EC2 deployment guide  
- [`eks-containerized/README.md`](eks-containerized/README.md) - EKS deployment guide

## 🔄 CI/CD Workflows

GitHub Actions workflows are configured with **path filters** to only trigger when relevant code changes:

- **S3 Workflow** (`.github/workflows/deploy-s3.yml`) - Triggers on `s3-serverless/**` changes
- **EC2 Workflow** (`.github/workflows/deploy-ec2.yml`) - Triggers on `ec2-solution/**` changes
- **EKS Workflow** (Coming Soon) - Will trigger on `eks-containerized/**` changes

## 📊 Solution Comparison

| Feature | S3 Serverless | EC2 Solution | EKS Containerized |
|---------|---------------|--------------|-------------------|
| **Cost** | ~$1-5/month | ~$20-50/month | ~$50-100/month |
| **Scalability** | Auto (Global) | Manual/Auto | Auto (Cluster) |
| **Complexity** | Low | Medium | High |
| **Control** | Limited | Full | Full |
| **Best For** | Static + API | Traditional Apps | Microservices |

## 🛠️ Development

### Prerequisites
- AWS Account with appropriate permissions
- GitHub repository with secrets configured
- Domain name (optional, for custom domains)

### Required GitHub Secrets
```
AWS_ACCESS_KEY_ID          # AWS credentials
AWS_SECRET_ACCESS_KEY      # AWS credentials  
SSH_PRIVATE_KEY           # EC2 SSH access (EC2 solution only)
```

### Local Development
```bash
# Clone the repository
git clone https://github.com/ColmCharlton/resume-website-demo.git
cd resume-website-demo

# Choose your solution
cd s3-serverless    # or ec2-solution, eks-containerized
```

## 📚 Documentation

- [`docs/architecture.md`](docs/architecture.md) - Detailed architecture diagrams
- [`docs/deployment-guide.md`](docs/deployment-guide.md) - Step-by-step deployment
- [`docs/best-practices.md`](docs/best-practices.md) - Security and optimization tips

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

**🎯 Goal**: Demonstrate multiple cloud deployment patterns for a single application, showcasing different trade-offs between cost, complexity, and capabilities.