variable "pipeline_name" {
  type        = string
  description = "Name of the Image Builder pipeline"
  default     = "windows-server-2022-pipeline"
}

variable "pipeline_description" {
  type        = string
  description = "Description of the Image Builder pipeline"
  default     = "Pipeline for creating Windows Server 2022 images with latest updates"
}

variable "image_name" {
  type        = string
  description = "Name of the image"
  default     = "windows-server-2022"
}

variable "image_tests_timeout_minutes" {
  type        = number
  description = "Timeout in minutes for image tests"
  default     = 60
}

variable "distribution_regions" {
  type        = list(string)
  description = "List of regions to distribute the image to"
  default     = ["ap-southeast-1"]
}

variable "organization_arn" {
  type        = string
  description = "ARN of the AWS Organization"
}

variable "organization_id" {
  description = "AWS Organization ID for KMS key policy"
  type        = string
  default     = "o-123example" # Replace with your actual org ID
}

variable "schedule_cron" {
  type        = string
  description = "Cron expression for pipeline schedule"
  default     = "0 0 ? * TUE#2 *"
}

variable "schedule_tz" {
  type        = string
  description = "Timezone for pipeline schedule"
  default     = "UTC"
}

variable "recipe_version" {
  type        = string
  description = "Version of the image recipe"
  default     = "1.0.0"
}

variable "recipe_platform" {
  type        = string
  description = "Platform for the image recipe"
  default     = "Windows"
}

variable "recipe_working_directory" {
  type        = string
  description = "Working directory for the image recipe"
  default     = "C:\\Windows\\Temp"
}

variable "component_arns" {
  type        = list(string)
  description = "List of component ARNs for the recipe"
  default     = []
}

variable "root_device_name" {
  type        = string
  description = "Root device name for Windows instance"
  default     = "/dev/sda1"
}

variable "root_volume_size" {
  type        = number
  description = "Size of the root volume in GB"
  default     = 50
}

variable "root_volume_type" {
  type        = string
  description = "Type of the root volume (gp2, gp3, io1, etc)"
  default     = "gp3"
}

variable "root_volume_iops" {
  type        = number
  description = "IOPS for the root volume (required for io1/io2)"
  default     = 3000
}
