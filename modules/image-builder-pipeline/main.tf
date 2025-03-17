# Create IAM role for Image Builder
resource "aws_iam_role" "image_builder_role" {
  name = "${var.pipeline_name}-image-builder-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["ec2.amazonaws.com", "imagebuilder.amazonaws.com"]
        }
      }
    ]
  })

  tags = var.tags
}

# Attach necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "image_builder_service_policy" {
  role       = aws_iam_role.image_builder_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSImageBuilderFullAccess"
}

# Attach SSM Managed Instance Core policy
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.image_builder_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach EC2 Instance Profile for Image Builder policy
resource "aws_iam_role_policy_attachment" "ec2_image_builder_policy" {
  role       = aws_iam_role.image_builder_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
}

# Create security group
resource "aws_security_group" "image_builder" {
  name        = "${var.pipeline_name}-sg"
  description = "Security group for Image Builder pipeline"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Create IAM instance profile
resource "aws_iam_instance_profile" "image_builder" {
  name = aws_iam_role.image_builder_role.name
  role = aws_iam_role.image_builder_role.name
}

# Create infrastructure configuration
resource "aws_imagebuilder_infrastructure_configuration" "config" {
  name                          = "${var.pipeline_name}-infra-config"
  instance_types                = var.instance_types
  instance_profile_name         = aws_iam_instance_profile.image_builder.name
  subnet_id                     = var.subnet_id
  security_group_ids            = length(var.security_groups) > 0 ? var.security_groups : [aws_security_group.image_builder.id]
  terminate_instance_on_failure = true
  sns_topic_arn                 = var.sns_topic_arn

  tags = var.tags
}


# Create distribution configuration
resource "aws_imagebuilder_distribution_configuration" "distribution" {
  name = "${var.pipeline_name}-distribution"

  dynamic "distribution" {
    for_each = var.regions
    content {
      region = distribution.value
      ami_distribution_configuration {
        name       = "${var.image_name}-{{ imagebuilder:buildDate }}"
        kms_key_id = var.kms_key_id

        dynamic "launch_permission" {
          for_each = var.organization_arn != null ? [1] : []
          content {
            organization_arns = [var.organization_arn]
          }
        }

        ami_tags = merge(
          var.tags,
          {
            Name = var.image_name
          }
        )
      }
    }
  }

  tags = var.tags
}

# Create image pipeline
resource "aws_imagebuilder_image_pipeline" "pipeline" {
  name                             = var.pipeline_name
  description                      = var.description
  image_recipe_arn                 = var.image_recipe_arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.config.arn
  distribution_configuration_arn   = aws_imagebuilder_distribution_configuration.distribution.arn

  dynamic "schedule" {
    for_each = var.schedule_cron != null ? [1] : []
    content {
      schedule_expression                = "cron(${var.schedule_cron})"
      timezone                           = var.schedule_tz
      pipeline_execution_start_condition = "EXPRESSION_MATCH_AND_DEPENDENCY_UPDATES_AVAILABLE"
    }
  }

  image_tests_configuration {
    image_tests_enabled = var.image_tests_enabled
    timeout_minutes     = var.image_tests_timeout_minutes
  }

  tags = var.tags
}

# Outputs
output "pipeline_arn" {
  value       = aws_imagebuilder_image_pipeline.pipeline.arn
  description = "ARN of the Image Builder pipeline"
}

output "infrastructure_configuration_arn" {
  value       = aws_imagebuilder_infrastructure_configuration.config.arn
  description = "ARN of the Image Builder infrastructure configuration"
}

output "distribution_configuration_arn" {
  value       = aws_imagebuilder_distribution_configuration.distribution.arn
  description = "ARN of the Image Builder distribution configuration"
}

