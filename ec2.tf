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
    encrypted             = true
    kms_key_id            = aws_kms_key.ec2.arn
    delete_on_termination = true
  }

  disable_api_termination = var.ec2_protect_termination

  user_data = <<-EOF
    #!/bin/bash
    rm -f /opt/webapp/.env  # Remove the old .env file

    # Install necessary tools
    yum install -y jq aws-cli

    # Install AWS CLI v2
    cd /tmp
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install
    export PATH=$PATH:/usr/local/bin

    # Fetch the database credentials from Secrets Manager
    SECRET_JSON=$(aws secretsmanager get-secret-value \
      --region ${var.aws_region} \
      --secret-id ${aws_secretsmanager_secret.db_password.name} \
      --query 'SecretString' \
      --output text)

    DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')

    # Validate the password is extracted
    if [ -z "$DB_PASSWORD" ]; then
      echo "Failed to retrieve DB password from Secrets Manager." >&2
      exit 1
    fi

    # Create the new .env file with the correct values
    # echo "DATABASE_URL=postgres://${var.db_username}:${var.db_password}@${aws_db_instance.main.endpoint}/${var.db_name}" > /opt/webapp/.env
    echo "DB_HOST=$(echo "${aws_db_instance.main.endpoint}" | sed 's/:.*//')" >> /opt/webapp/.env
    echo "DB_PORT=${var.rds_sg_ingress_port}" >> /opt/webapp/.env
    echo "DB_USER=${var.db_username}" >> /opt/webapp/.env
    echo "DB_PASSWORD=$DB_PASSWORD" >> /opt/webapp/.env
    echo "DB_NAME=${var.db_name}" >> /opt/webapp/.env
    echo "DB_DIALECT=${var.db_engine}" >> /opt/webapp/.env
    echo "S3_BUCKET=${aws_s3_bucket.private_bucket.bucket}" >> /opt/webapp/.env
    echo "AWS_REGION=${var.aws_region}" >> /opt/webapp/.env
    echo "AWS_PROFILE=${var.aws_profile}" >> /opt/webapp/.env

    # Create CloudWatch Agent configuration file
    sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

    sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-config.json > /dev/null <<'EOC'
    {
      "agent": {
        "metrics_collection_interval": 10,
        "logfile": "/var/log/cloudwatch-config.log"
      },
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/csye6225.log",
                "log_group_name": "csye6225",
                "log_stream_name": "webapp"
              }
            ]
          }
        }
      },
      "metrics": {
        "metrics_collected": {
          "statsd": {
            "service_address": ":8125",
            "metrics_collection_interval": 10,
            "metrics_aggregation_interval": 60,
            "metric_separator": "."
          },
          "cpu": {                     
            "measurement": [
              "cpu_usage_idle",
              "cpu_usage_user",
              "cpu_usage_system"
            ],
            "metrics_collection_interval": 10,
            "totalcpu": true
          }
        }
      }
    }
    EOC

    # Run the CloudWatch Agent with the provided configuration
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-config.json -s

    sudo systemctl restart amazon-cloudwatch-agent

    sudo systemctl restart webapp.service
 EOF

  tags = {
    Name = "App Instance-${var.env_name}"
  }
}

