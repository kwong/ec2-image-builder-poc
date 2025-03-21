output "component_arn" {
  description = "ARN of the created Image Builder component"
  value       = aws_imagebuilder_component.shell.arn
}
