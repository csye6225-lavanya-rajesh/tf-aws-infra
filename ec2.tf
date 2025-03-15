resource "aws_instance" "app_server" {
  ami                    = var.ec2_ami_id
  instance_type          = var.ec2_instance_type
  key_name               = var.ec2_key_pair
  subnet_id              = element(aws_subnet.public[*].id, 0)  # Pick first available subnet
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  root_block_device {
    volume_size           = var.ec2_root_volume_size
    volume_type           = var.ec2_root_volume_type
    delete_on_termination = true
  }

  disable_api_termination = var.ec2_protect_termination

  tags = {
    Name = "App Instance-${var.env_name}"
  }
}
