# VPC for Image Builder Pipeline
resource "aws_vpc" "image_builder" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "image-builder-vpc"
  }
}

# Public subnet for Image Builder
resource "aws_subnet" "image_builder" {
  vpc_id                  = aws_vpc.image_builder.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_region.current.name}a"
  tags = {
    Name = "image-builder-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "image_builder" {
  vpc_id = aws_vpc.image_builder.id

  tags = {
    Name = "image-builder-igw"
  }
}

# Route table
resource "aws_route_table" "image_builder" {
  vpc_id = aws_vpc.image_builder.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.image_builder.id
  }

  tags = {
    Name = "image-builder-rt"
  }
}

# Route table association
resource "aws_route_table_association" "image_builder" {
  subnet_id      = aws_subnet.image_builder.id
  route_table_id = aws_route_table.image_builder.id
}

# Random string for S3 bucket name
resource "random_string" "bucket_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Create S3 bucket for Image Builder logs
resource "aws_s3_bucket" "image_builder_logs" {
  bucket = "image-pipeline-logs-${data.aws_caller_identity.current.account_id}-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "Image Builder Logs"
    Environment = "Production"
  }


}

# Enable versioning for the bucket
resource "aws_s3_bucket_versioning" "image_builder_logs" {
  bucket = aws_s3_bucket.image_builder_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "image_builder_logs" {
  bucket = aws_s3_bucket.image_builder_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Update S3 bucket to use KMS encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "image_builder_logs" {
  bucket = aws_s3_bucket.image_builder_logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = data.aws_kms_key.cmk_non_db.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

module "windows_server_2022_pipeline" {
  source = "./modules/image-builder-pipeline"

  # Basic configuration
  pipeline_name    = var.pipeline_name
  description      = var.pipeline_description
  image_name       = var.image_name
  image_recipe_arn = module.windows_2022_recipe.recipe_arn

  # Network configuration
  vpc_id    = aws_vpc.image_builder.id
  subnet_id = aws_subnet.image_builder.id

  # Testing configuration
  image_tests_enabled         = true
  image_tests_timeout_minutes = var.image_tests_timeout_minutes

  # Distribution configuration
  regions          = var.distribution_regions
  organization_arn = var.organization_arn

  # Schedule configuration
  schedule_cron = var.schedule_cron
  schedule_tz   = var.schedule_tz

  # Logging configuration
  logging_bucket = aws_s3_bucket.image_builder_logs.id

  # Add KMS key for AMI encryption
  kms_key_id = aws_kms_key.image_builder.arn

  tags = {
    Environment = "Production"
    Purpose     = "Windows Server 2022 Image Creation"
  }

  depends_on = [module.windows_2022_recipe]
}

module "windows_2022_recipe" {
  source = "./modules/image-builder-recipe"

  name           = var.image_name
  description    = var.pipeline_description
  recipe_version = var.recipe_version
  platform       = var.recipe_platform
  parent_image   = data.aws_ami.windows_2022.id

  working_directory = var.recipe_working_directory
  update            = true
  kms_key_id        = aws_kms_key.image_builder.arn

  # Attach component to recipe
  component_arns = [
    module.hello_world_component.component_arn
  ]

  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      ebs = {
        volume_size           = 100
        volume_type           = "gp3"
        encrypted             = true
        kms_key_id            = aws_kms_key.image_builder.arn
        delete_on_termination = true
        throughput            = 125
      }
    }
  ]

  tags = {
    Name        = var.image_name
    Environment = "Production"
    OS          = "Windows"
    Version     = "2022"
  }
}


# Create IAM policy for S3 logging
resource "aws_iam_role_policy" "image_builder_s3_logs" {
  name = "image-builder-s3-logs"
  role = module.windows_server_2022_pipeline.image_builder_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.image_builder_logs.arn,
          "${aws_s3_bucket.image_builder_logs.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt",
          "kms:Encrypt"
        ]
        Resource = [
          data.aws_kms_key.cmk_non_db.arn,
          aws_kms_key.image_builder.arn
        ]
      }
    ]
  })
}

# Create component to print hello world 
module "hello_world_component" {
  source = "./modules/image-builder-component-shell"

  component_name = "HelloWorld"
  platform       = "Windows"
  commands = [
    "$ErrorActionPreference = 'Stop'",
    "Write-Error 'Hello, World! This will now exit with an error' -ErrorAction Stop"
  ]
  on_failure = "Abort"
  tags = {
    Environment = "Production"
  }
}

