resource "aws_imagebuilder_component" "shell" {
  name        = var.component_name
  description = var.description
  platform    = var.platform
  version     = var.component_version

  data = yamlencode({
    schemaVersion = 1.0
    phases = [
      {
        name = "build"
        steps = [
          {
            name      = "ExecuteShellCommand"
            action    = var.platform == "Windows" ? "ExecutePowerShell" : "ExecuteBash"
            onFailure = var.on_failure
            inputs = {
              commands = var.commands
            }
          }
        ]
      }
    ]
  })

  tags = var.tags
}
