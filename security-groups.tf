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