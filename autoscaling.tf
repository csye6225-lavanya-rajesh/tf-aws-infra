resource "aws_launch_template" "webapp_launch_template" {
  name_prefix   = "csye6225-asg-template"
  image_id      = var.ec2_ami_id        # Replace with your custom AMI ID
  instance_type = var.ec2_instance_type # Replace with the desired instance type, or use ANY
  key_name      = var.ec2_key_pair      # Replace with your AWS key name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name # Replace with the IAM role for EC2 instances
  }

  block_device_mappings {
    device_name = "/dev/sda1" # Root device for your AMI
    ebs {
      volume_size = var.ec2_root_volume_size
      volume_type = var.ec2_root_volume_type
      encrypted   = true
      kms_key_id  = aws_kms_key.ec2.arn # Your EC2-specific KMS key
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    rm -f /opt/webapp/.env  # Remove the old .env file

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
  )

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_sg.id]
  }

  depends_on = [
    aws_kms_key.ec2,
    aws_iam_instance_profile.ec2_profile
  ]
}

resource "aws_autoscaling_group" "webapp_asg" {
  name                      = "csye6225-asg"
  desired_capacity          = 3
  min_size                  = 3
  max_size                  = 5
  vpc_zone_identifier       = aws_subnet.public[*].id
  health_check_type         = "ELB"
  health_check_grace_period = 300
  force_delete              = true
  target_group_arns         = [aws_lb_target_group.webapp_target_group.arn]

  launch_template {
    id      = aws_launch_template.webapp_launch_template.id
    version = "$Latest"
  }

  # Correct way to add tags to instances in Auto Scaling Group
  tag {
    key                 = "AutoScalingGroup"
    value               = "csye6225-asg"
    propagate_at_launch = true
  }
}

# Scale Up Policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

# Scale Down Policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 10
  alarm_description   = "Scale up when CPU > 9% for 2 periods"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "low-cpu-utilization"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 7
  alarm_description   = "Scale down when CPU < 7% for 2 periods"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}