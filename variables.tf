variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "dev"
}

variable "env_name" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "route_table_tags" {
  description = "Tags for the route tables"
  type        = map(string)
  default = {
    public  = "tf-public-route-table"
    private = "tf-private-route-table"
  }
}

variable "default_cidr_block" {
  description = "CIDR block for the default route"
  type        = string
  default     = "0.0.0.0/0"
}

variable "security_group_name" {
  description = "Name for the security group"
  type        = string
  default     = "default security group"
}

variable "security_group_ingress_ports" {
  description = "List of ports allowed for ingress (e.g., 80 for HTTP)"
  type        = list(number)
  default     = [80]
}

variable "security_group_ingress_cidr" {
  description = "List of CIDR blocks allowed for ingress traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "security_group_egress_ports" {
  description = "List of ports allowed for egress (e.g., 0 for all ports)"
  type        = list(number)
  default     = [0]
}

variable "security_group_egress_cidr" {
  description = "List of CIDR blocks allowed for egress traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_port" {
  description = "The port on which the application runs"
  type        = number
  default     = 8080 # Change this if needed
}

variable "app_sg_name" {
  description = "Name of the application security group"
  type        = string
  default     = "application security group"
}

variable "app_sg_description" {
  description = "Description of the application security group"
  type        = string
  default     = "Security group for EC2 web application"
}

variable "app_sg_ingress_ssh_ports" {
  description = "List of SSH ports allowed for ingress"
  type        = list(number)
  default     = [22] # Default to SSH
}

variable "app_sg_ingress_web_ports" {
  description = "List of web ports allowed for ingress"
  type        = list(number)
  default     = [80, 443] # HTTP and HTTPS
}

variable "app_sg_ingress_cidr" {
  description = "CIDR blocks allowed for application ingress"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_sg_egress_cidr" {
  description = "CIDR blocks allowed for application egress"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# EC2 Instance Variables
variable "ec2_instance_type" {
  description = "The type of EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "ec2_ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "ec2_root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 25
}

variable "ec2_root_volume_type" {
  description = "Type of the root volume"
  type        = string
  default     = "gp2"
}

variable "ec2_key_pair" {
  description = "The key pair to access the instance"
  type        = string
  default     = "csye6225"
}

# variable "ec2_subnet_id" {
#   description = "Subnet ID where the EC2 instance will be launched"
#   type        = string
# }

variable "ec2_protect_termination" {
  description = "Enable or disable termination protection"
  type        = bool
  default     = false
}