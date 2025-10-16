# Architecture Overview

## Multi-Solution Resume Website Architecture

This repository demonstrates three different cloud deployment architectures for the same resume website application.

## Solution Architectures

### 1. S3 Serverless Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   CloudFront    │────│      S3 Bucket   │    │   Lambda APIs   │
│   (Global CDN)  │    │   (Static Files) │    │ (Contact/Count) │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                        │
         └────────────────────────┼────────────────────────┘
                                  │
                            ┌──────────────────┐
                            │   API Gateway    │
                            │  (REST Endpoints)│
                            └──────────────────┘
```

**Key Components:**
- **CloudFront CDN** - Global content delivery
- **S3 Static Hosting** - HTML, CSS, JS files
- **Lambda Functions** - Contact form and visitor counter
- **API Gateway** - RESTful API endpoints
- **DynamoDB** - Data storage (visitors, messages)

### 2. EC2 Traditional Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Application    │    │   Bastion Host   │    │   Load Balancer │
│  Load Balancer  │    │  (SSH Gateway)   │    │   (Optional)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                        │
         └────────────────────────┼────────────────────────┘
                                  │
                    ┌──────────────────────────┐
                    │      EC2 Instance        │
                    │  ┌─────────┐ ┌─────────┐ │
                    │  │  Nginx  │ │  Flask  │ │
                    │  │ (Proxy) │ │  (App)  │ │
                    │  └─────────┘ └─────────┘ │
                    └──────────────────────────┘
```

**Key Components:**
- **EC2 Instances** - Application servers
- **Nginx** - Reverse proxy and SSL termination
- **Flask Application** - Python web framework
- **Bastion Host** - Secure SSH access
- **Security Groups** - Network-level firewall
- **Lambda Functions** - Background processing

### 3. EKS Containerized Architecture (Planned)

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Ingress       │    │    EKS Cluster   │    │   Auto Scaling  │
│  Controller     │    │   (Kubernetes)   │    │     Groups      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                        │                        │
         └────────────────────────┼────────────────────────┘
                                  │
                    ┌──────────────────────────┐
                    │      Worker Nodes        │
                    │  ┌─────────┐ ┌─────────┐ │
                    │  │   Pod   │ │   Pod   │ │
                    │  │(Nginx)  │ │(Flask)  │ │
                    │  └─────────┘ └─────────┘ │
                    └──────────────────────────┘
```

**Planned Components:**
- **EKS Cluster** - Managed Kubernetes
- **Docker Containers** - Application packaging
- **Helm Charts** - Kubernetes package management
- **HPA** - Horizontal Pod Autoscaler
- **Prometheus/Grafana** - Monitoring stack

## Deployment Methods

### S3 Serverless
- **AWS CodePipeline** with buildspec files
- **Terraform** for infrastructure
- **Automated** S3 sync and CloudFront invalidation

### EC2 Traditional  
- **GitHub Actions** for CI/CD
- **Terraform** for infrastructure provisioning
- **Ansible** for server configuration

### EKS Containerized (Planned)
- **GitHub Actions** for CI/CD
- **Terraform** for EKS cluster
- **Helm** for application deployment
- **Docker** for containerization

## Security Considerations

### S3 Serverless
- ✅ No server management required
- ✅ AWS managed security updates
- ✅ IAM-based access control
- ⚠️ Limited customization options

### EC2 Traditional
- ✅ Full control over security configuration
- ✅ Custom firewall rules
- ✅ Bastion host architecture
- ⚠️ Manual security updates required

### EKS Containerized
- ✅ Container-level isolation
- ✅ Kubernetes RBAC
- ✅ Network policies
- ⚠️ Complex security configuration