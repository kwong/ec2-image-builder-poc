# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current region
data "aws_region" "current" {}

# Get the CMK ARN
data "aws_kms_key" "cmk_non_db" {
  key_id = "alias/non-db-customer-key"
}

# Get latest Windows Server 2022 AMI
data "aws_ami" "windows_2022" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
} 
