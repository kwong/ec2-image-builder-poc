locals {
  update_component = var.update ? [
    var.platform == "Windows" ?
    "arn:aws:imagebuilder:${data.aws_region.current.name}:aws:component/update-windows/x.x.x" :
    "arn:aws:imagebuilder:${data.aws_region.current.name}:aws:component/update-linux/x.x.x"
  ] : []

  all_components = concat(
    local.update_component,
    var.component_arns
  )
}

resource "aws_imagebuilder_image_recipe" "recipe" {
  name              = var.name
  description       = var.description
  version           = var.recipe_version
  parent_image      = var.parent_image
  working_directory = var.working_directory
  user_data_base64  = var.user_data

  dynamic "component" {
    for_each = local.all_components
    content {
      component_arn = component.value
    }
  }

  # dynamic "systems_manager_agent" {
  #   for_each = var.platform == "Windows" ? [1] : []
  #   content {
  #     uninstall_after_build = false
  #   }
  # }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
