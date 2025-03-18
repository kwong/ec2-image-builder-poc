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

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Create S3 bucket for Image Builder logs
resource "aws_s3_bucket" "image_builder_logs" {
  bucket = "image-pipeline-logs-${data.aws_caller_identity.current.account_id}"

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

module "windows_server_2022_pipeline" {
  source = "./modules/image-builder-pipeline"

  # Basic configuration
  pipeline_name    = "windows-server-2022-pipeline"
  description      = "Pipeline for creating Windows Server 2022 images with latest updates"
  image_name       = "windows-server-2022"
  image_recipe_arn = module.windows_2022_recipe.recipe_arn

  # Network configuration
  vpc_id    = aws_vpc.image_builder.id
  subnet_id = aws_subnet.image_builder.id

  # Testing configuration
  image_tests_enabled         = true
  image_tests_timeout_minutes = 120

  # Distribution configuration
  regions = ["ap-southeast-1"]

  # Schedule configuration (optional)
  schedule_cron = "0 0 ? * TUE#2 *" # AWS cron format: run at midnight on the second Tuesday of every month
  schedule_tz   = "UTC"

  # Logging configuration
  logging_bucket = aws_s3_bucket.image_builder_logs.id
  logging_prefix = "windows-server-2022/"

  # Tags
  tags = {
    Environment = "Production"
    Purpose     = "Windows Server 2022 Image Creation"
  }
}

# Data source for current region
data "aws_region" "current" {}

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

# Create Windows Server 2022 recipe
module "windows_2022_recipe" {
  source = "./modules/image-builder-recipe"

  name           = "windows-server-2022"
  description    = "Windows Server 2022 with latest updates"
  recipe_version = "1.0.0"
  platform       = "Windows"
  parent_image   = data.aws_ami.windows_2022.id

  working_directory = "C:\\Windows\\Temp"
  update            = true

  # Add any additional component ARNs if needed
  component_arns = []

  tags = {
    Name        = "windows-server-2022"
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
      }
    ]
  })
}
