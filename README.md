# AWS Networking Infrastructure with Terraform

This project contains terraform configuration files to set up a Virtual Private Cloud (VPC) and its associcated networking infrastructure on AWS.

## Key Resources Created

- **VPC**: Virtual Private Cloud to isolate network resources.
- **Subnets**: Three public and three private subnets, each in different availability zones.
- **Internet Gateway**: Provides internet access to public subnet.
- **Route Tables**: For both public and private subnets.
- **Security Groups**: Default security group for controlling inbound and outbound traffic.

## Prerequisites

- Terraform (v0.12 or higher) installed.
- AWS CLI installed and configured with a valid AWS profile.
- An AWS account with sufficient permissions to create VPCs.

## Setup 

**1. Clone the Repository**

```bash
git clone <repository-url>
cd <project-directory>
```

**2. Confiure AWS Credentials** - Run the below command on terminal

```bash
aws configure
```

**3. Update / Create a terraform.tfvars filee** - Add the following in the file

```bash
aws_profile     = "dev"
aws_region      = "us-east-1"
vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
```

**4. Initialize Terraform** - Run the below commands on terminal

```bash
terraform init
terraform fmt
```

**6. Validate the Configuration** - Run the below command on terminal.

```bash
terraform validate
```

**7. Preview / Plan the Configuration** - Run the below command on terminal.

```bash
terraform plan
```
OR
```bash
terraform plan -var-file=terraform.tfvars    
```

**7. Apply the Configuration** - Run the below command on terminal.

```bash
terraform apply
```
OR
```bash
terraform apply -var-file=terraform.tfvars    
```