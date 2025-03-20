# Recipe basic configuration
variable "name" {
  type        = string
  description = "Name of the Image Builder recipe"
}

variable "description" {
  type        = string
  description = "Description of the Image Builder recipe"
}

variable "recipe_version" {
  type        = string
  description = "Version of the recipe in semver format (x.x.x)"
}

variable "platform" {
  type        = string
  description = "Platform for the recipe (Linux or Windows)"
  validation {
    condition     = contains(["Linux", "Windows"], var.platform)
    error_message = "Platform must be either 'Linux' or 'Windows'."
  }
}

# Components configuration
variable "component_arns" {
  type        = list(string)
  description = "List of component ARNs to be used in the recipe in order"
}

# Parent image configuration
variable "parent_image" {
  type        = string
  description = "Parent image ARN or ID for the recipe"
}

# Build configuration
variable "working_directory" {
  type        = string
  description = "Working directory to use in the build instance"
  default     = null
}

variable "user_data" {
  type        = string
  description = "Base64 encoded user-data script"
  default     = null
}

# Update configuration
variable "update" {
  type        = bool
  description = "Whether recipe should include the update component"
  default     = true
}

# Tags
variable "tags" {
  type        = map(string)
  description = "Tags to apply to the recipe"
  default     = {}
}

variable "block_device_mappings" {
  description = "List of block device mappings for the image recipe"
  type = list(object({
    device_name           = string
    delete_on_termination = optional(bool)
    encrypted             = optional(bool)
    iops                  = optional(number)
    kms_key_id            = optional(string)
    snapshot_id           = optional(string)
    volume_size           = optional(number)
    volume_type           = optional(string)
  }))
  default = []
}

variable "kms_key_id" {
  type        = string
  description = "KMS key ID for encrypting the root volume"
}
