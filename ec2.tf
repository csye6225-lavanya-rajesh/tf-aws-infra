resource "aws_instance" "app_server" {
  ami                    = var.ec2_ami_id
  instance_type          = var.ec2_instance_type
  key_name               = var.ec2_key_pair
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  subnet_id              = element(aws_subnet.public[*].id, 0) # Pick first available subnet
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  root_block_device {
    volume_size           = var.ec2_root_volume_size
    volume_type           = var.ec2_root_volume_type
    delete_on_termination = true
  }

  disable_api_termination = var.ec2_protect_termination

  user_data = <<-EOF
    #!/bin/bash
    rm -f /opt/webapp/webapp/.env  # Remove the old .env file

    # Create the new .env file with the correct values
    # echo "DATABASE_URL=postgres://${var.db_username}:${var.db_password}@${aws_db_instance.main.endpoint}/${var.db_name}" > /opt/webapp/webapp/.env
    echo "DB_HOST=$(echo "${aws_db_instance.main.endpoint}" | sed 's/:.*//')" >> /opt/webapp/webapp/.env
    echo "DB_PORT=${var.rds_sg_ingress_port}" >> /opt/webapp/webapp/.env
    echo "DB_USER=${var.db_username}" >> /opt/webapp/webapp/.env
    echo "DB_PASSWORD=${var.db_password}" >> /opt/webapp/webapp/.env
    echo "DB_NAME=${var.db_name}" >> /opt/webapp/webapp/.env
    echo "DB_DIALECT=postgres" >> /opt/webapp/webapp/.env
    echo "S3_BUCKET=${aws_s3_bucket.private_bucket.bucket}" >> /opt/webapp/webapp/.env
    echo "AWS_REGION=${var.aws_region}" >> /opt/webapp/webapp/.env
    echo "AWS_PROFILE=${var.aws_profile}" >> /opt/webapp/webapp/.env

    sudo systemctl restart webapp.service
  EOF

  tags = {
    Name = "App Instance-${var.env_name}"
  }
}

