# Default Security Group
resource "aws_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = var.security_group_ingress_ports[0]
    to_port     = var.security_group_ingress_ports[0]
    protocol    = "tcp"
    cidr_blocks = var.security_group_ingress_cidr
  }

  egress {
    from_port   = var.security_group_egress_ports[0]
    to_port     = var.security_group_egress_ports[0]
    protocol    = "-1"
    cidr_blocks = var.security_group_egress_cidr
  }

  tags = {
    Name = var.security_group_name
  }
}

# Application Security Group for EC2 Instances
resource "aws_security_group" "app_sg" {
  name        = var.app_sg_name
  description = var.app_sg_description
  vpc_id      = aws_vpc.main.id

  # Allow SSH access
  dynamic "ingress" {
    for_each = var.app_sg_ingress_ssh_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.app_sg_ingress_cidr
    }
  }

  # Allow HTTP and HTTPS access
  dynamic "ingress" {
    for_each = var.app_sg_ingress_web_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.app_sg_ingress_cidr
    }
  }

  # Allow custom application port
  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = var.app_sg_ingress_cidr
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.app_sg_egress_cidr
  }

  tags = {
    Name = var.app_sg_name
  }
}
