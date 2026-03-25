## Prerequisites

- Python 3.13
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform](https://developer.hashicorp.com/terraform/install)
- [Packer](https://developer.hashicorp.com/packer/install)

## Local Deployment

1. Copy `.env.example` to `.env` and fill in values.
   | Variable | Description |
   |---|---|
   | `AWS_REGION` | AWS region to deploy in |
   | `AVAILABILITY_ZONE` | Specific AZ within the region (optional, auto-selects if empty) |
   | `DOMAIN_NAME` | Domain name for the web server |
   | `CERTBOT_EMAIL` | Email for Let's Encrypt certificate notifications |
   | `INSTANCE_TYPE` | EC2 instance type (e.g. `t3.micro`, `t4g.micro`) |
   | `VPC_CIDR` | CIDR block for the VPC |
   | `PROJECT_NAME` | Identifier used for resource tagging |
   | `ENVIRONMENT` | Deployment environment (e.g. `production`) |
   | `TARGET_OS` | `linux` (Amazon Linux 2023) or `windows` (Windows Server 2022) |
2. Create and activate a virtual environment.
   ```sh
   python3.13 -m venv .venv
   source .venv/bin/activate
   ```
3. `aws configure` to set up AWS credentials for Terraform and Packer.
4. `make install` to install dependencies (Ansible, pywinrm).
5. `make ami` to build a custom EC2 AMI with Packer and Ansible, pre-configured with Nginx and automatic HTTPS (Certbot on Linux, Win-ACME on Windows).
6. `make init` to initialize Terraform state and download provider plugins.
7. `make deploy` to create the infrastructure: VPC, security groups, EC2 instance, Elastic IP, and Route53 DNS records.

## Production Considerations

- **S3 backend for Terraform state** — remote state with S3 and DynamoDB for locking, enabling team collaboration, state versioning, and encryption at rest.
- **Kubernetes (EKS)** — where managed services are acceptable, for container orchestration, rolling deployments, auto-scaling, and self-healing pods.
- **Application Load Balancer** — health checks, SSL termination, and traffic distribution across instances.
- **Multiple Availability Zones** — high availability and fault tolerance across AZ failures.
- **CDN (CloudFront)** — edge caching, reduced latency, DDoS protection, and lower origin load.
