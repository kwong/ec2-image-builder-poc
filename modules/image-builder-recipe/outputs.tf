output "recipe_arn" {
  value       = aws_imagebuilder_image_recipe.recipe.arn
  description = "ARN of the created Image Builder recipe"
}

output "recipe_name" {
  value       = aws_imagebuilder_image_recipe.recipe.name
  description = "Name of the created Image Builder recipe"
} 
