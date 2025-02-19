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
  default     = "tf-default-security-group"
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
