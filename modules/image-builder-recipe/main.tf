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

  dynamic "block_device_mapping" {
    for_each = var.block_device_mappings
    content {
      device_name = lookup(block_device_mapping.value, "device_name", null)

      dynamic "ebs" {
        for_each = lookup(block_device_mapping.value, "ebs", {}) == 0 ? [] : [lookup(block_device_mapping.value, "ebs", {})]
        content {
          encrypted             = lookup(ebs.value, "encrypted", true)
          iops                  = lookup(ebs.value, "iops", null)
          kms_key_id            = lookup(ebs.value, "kms_key_id", var.kms_key_id)
          snapshot_id           = lookup(ebs.value, "snapshot_id", null)
          volume_size           = lookup(ebs.value, "volume_size", 50)
          volume_type           = lookup(ebs.value, "volume_type", "gp3")
          delete_on_termination = lookup(ebs.value, "delete_on_termination", true)
        }
      }
    }
  }
  # block_device_mapping {
  #   device_name = "/dev/sda1"
  #   ebs {
  #     volume_size           = 100
  #     volume_type           = "gp3"
  #     encrypted             = true
  #     kms_key_id            = var.kms_key_id
  #     delete_on_termination = true
  #     throughput            = 125
  #   }
  # }


  tags = var.tags

  lifecycle {
    create_before_destroy = false
  }
}
