resource "aws_db_parameter_group" "custom" {
  name        = var.db_parameter_group_name
  family      = "postgres17"
  description = "Custom parameter group for csye6225"

  parameter {
    name  = "timezone"
    value = "UTC"
  }

  tags = {
    Name = var.db_parameter_group_name
  }
}

resource "aws_db_instance" "main" {
  identifier              = var.db_instance_identifier
  engine                  = var.db_engine
  instance_class          = var.db_instance_class
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  parameter_group_name    = aws_db_parameter_group.custom.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  multi_az                = false
  publicly_accessible     = false
  storage_encrypted       = true
  allocated_storage       = var.db_storage_size
  backup_retention_period = 7
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.main.name

  tags = {
    Name = var.db_instance_identifier
  }
}

# Create the DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = var.db_subnet_group_name
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = var.db_subnet_group_name
  }
}