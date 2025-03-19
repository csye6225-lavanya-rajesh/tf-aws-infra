# Define IAM role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2_s3_access_role"

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

# Define IAM policy for S3 access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "ec2_s3_access_policy"
  description = "Allow EC2 instance to access S3 bucket"

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket"
        ],
        "Resource": "arn:aws:s3:::csye6225-${random_uuid.bucket_uuid.result}"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        "Resource": "arn:aws:s3:::csye6225-${random_uuid.bucket_uuid.result}/*"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "s3_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}
