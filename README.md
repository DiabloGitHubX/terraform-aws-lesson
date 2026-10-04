Terraform AWS Lesson

Terraform project for deploying a simple AWS infrastructure environment with separate development and production configurations.

Architecture

The Terraform configuration creates:

VPC
Public subnet
Internet Gateway
Public route table and route
Security Group
EC2 key pair
EC2 instance

All resources are deployed in the AWS eu-north-1 (Stockholm) region.

Environment Configuration

Development and production use separate configuration files:

environments/dev.tfvars
environments/prod.tfvars
Development
VPC CIDR: 10.0.0.0/16
Subnet CIDR: 10.0.1.0/24
EC2 instance: t3.micro
Environment tag: dev
Production
VPC CIDR: 10.1.0.0/16
Subnet CIDR: 10.1.1.0/24
EC2 instance: t3.small
Environment tag: prod

The production configuration intentionally uses a stronger EC2 instance size than development.

Resource Tagging

Resources use environment-specific tags:

Environment = dev / prod
Project     = terraform-aws-lesson
Name        = terraform-<environment>-<resource>

This makes resources easier to identify and manage.

Terraform State

Development and production use separate local Terraform state files:

states/
├── dev/
│   └── terraform.tfstate
└── prod/
    └── terraform.tfstate

The backend is selected during terraform init:

terraform init -reconfigure -backend-config=backend-dev.hcl

or:

terraform init -reconfigure -backend-config=backend-prod.hcl

State files are excluded from Git through .gitignore.

Security

SSH access is restricted to the administrator's public IP using a /32 security group rule.

HTTP port 80 is open for web-server testing.

The SSH private key is stored outside the repository and is never committed to Git.

Development Test

The development environment was deployed and tested successfully.

The EC2 instance was accessed through SSH and Nginx was installed and started:

sudo dnf install -y nginx
sudo systemctl enable --now nginx

The web server was tested both locally on the instance and through its public IP address.

After testing, the complete development environment was destroyed to avoid leaving unnecessary AWS resources running.

Production Safety

The production environment was validated using:

terraform plan -var-file="environments/prod.tfvars"

The plan confirmed:

Plan: 9 to add, 0 to change, 0 to destroy.

The production environment was not applied.

This demonstrates environment-specific infrastructure configuration and safe infrastructure planning without leaving production resources running unnecessarily.

Useful Commands
Development

Initialize the development backend:

terraform init -reconfigure -backend-config=backend-dev.hcl

Plan development:

terraform plan -var-file="environments/dev.tfvars"

Apply development:

terraform apply -var-file="environments/dev.tfvars"

Destroy development:

terraform destroy -var-file="environments/dev.tfvars"
Production

Initialize the production backend:

terraform init -reconfigure -backend-config=backend-prod.hcl

Plan production:

terraform plan -var-file="environments/prod.tfvars"

The production environment should only be applied when deployment is intentionally required.

Project Structure
terraform-aws-lesson/
├── environments/
│   ├── dev.tfvars
│   └── prod.tfvars
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── backend.tf
├── backend-dev.hcl
├── backend-prod.hcl
├── .gitignore
├── .terraform.lock.hcl
└── README.md
Validation

The final Terraform configuration was validated successfully with:

terraform validate

Result:

Success! The configuration is valid.