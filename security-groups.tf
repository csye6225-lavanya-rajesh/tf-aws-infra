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

resource "aws_security_group" "app_sg" {
  name        = var.app_sg_name
  description = var.app_sg_description
  vpc_id      = aws_vpc.main.id

  # Allow SSH access only from a specific source (optional)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow traffic from load balancer on app port
  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.loadbalancer_sg.id] # Allow traffic from load balancer security group
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


resource "aws_security_group" "rds_sg" {
  name        = var.rds_sg_name
  description = var.rds_sg_description
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = var.rds_sg_ingress_port
    to_port         = var.rds_sg_ingress_port
    protocol        = var.rds_sg_ingress_protocol
    security_groups = [aws_security_group.app_sg.id] # Reference EC2 security group
  }

  egress {
    from_port   = var.rds_sg_egress_port
    to_port     = var.rds_sg_egress_port
    protocol    = var.rds_sg_egress_protocol
    cidr_blocks = var.rds_sg_egress_cidr_blocks
  }

  tags = {
    Name = var.rds_sg_name
  }

  # Ensure RDS security group depends on the EC2 security group
  depends_on = [aws_security_group.app_sg]
}

resource "aws_security_group" "loadbalancer_sg" {
  name        = "load_balancer_sg"
  description = "Allow HTTP and HTTPS traffic to the Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "load-balancer-sg"
  }
}



