resource "aws_kms_key" "image_builder" {
  description             = "KMS key for Image Builder pipeline"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  multi_region            = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid       = "Allow access for organization root"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "kms:Describe*",
          "kms:List*",
          "kms:Get*",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = var.organization_id
          }
        }
      }
    ]
  })

  tags = {
    Name        = "image-builder-key"
    Environment = "Production"
  }
}

resource "aws_kms_alias" "image_builder" {
  name          = "alias/image-builder"
  target_key_id = aws_kms_key.image_builder.key_id
}
