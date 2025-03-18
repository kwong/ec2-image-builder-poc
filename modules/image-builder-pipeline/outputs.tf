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

output "image_builder_role_arn" {
  value       = aws_iam_role.image_builder_role.arn
  description = "ARN of the Image Builder IAM role"
}

output "image_builder_role_name" {
  value       = aws_iam_role.image_builder_role.name
  description = "Name of the Image Builder IAM role"
} 
