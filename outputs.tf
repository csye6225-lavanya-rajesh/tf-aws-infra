output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "s3_bucket_name" {
  description = "The unique UUID for the S3 bucket"
  value       = "csye6225-${random_uuid.bucket_uuid.result}"
}

data "aws_kms_key" "ec2_key_check" {
  key_id = aws_kms_alias.ec2_alias.id # Replace with your key alias/ARN
}

output "kms_key_state" {
  description = "key state"
  value       = data.aws_kms_key.ec2_key_check.key_state
}



