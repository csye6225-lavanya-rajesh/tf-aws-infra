resource "random_uuid" "bucket_uuid" {
  # Generates a unique UUID for the bucket name
}

resource "aws_s3_bucket" "private_bucket" {
  bucket = "csye6225-${random_uuid.bucket_uuid.result}"

  acl = "private"

  # Default encryption using SSE-S3
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  force_destroy = true # Allows Terraform to delete the bucket even if it's not empty

  tags = {
    Name = "csye6225-private-bucket"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_policy" {
  bucket = aws_s3_bucket.private_bucket.id

  rule {
    id     = "Transition to STANDARD_IA after 30 days"
    status = "Enabled"

    filter {
      prefix = "" # Apply to all objects in the bucket
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA" # Transition objects to Infrequent Access after 30 days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7 # Abort incomplete uploads after 7 days
    }
  }
}