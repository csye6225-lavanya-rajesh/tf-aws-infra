# Secrets Manager secret with randomized name
resource "aws_secretsmanager_secret" "db_password" {
  name       = "db-password-${random_pet.secrets_alias.id}"
  kms_key_id = aws_kms_key.secret.arn
}

# Random password for RDS without invalid characters
resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!#$%&" # Valid special characters allowed by AWS RDS
}

# Secrets Manager secret version
resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    password = random_password.rds_password.result
  })
}
