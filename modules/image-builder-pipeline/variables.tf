# Basic configuration
variable "pipeline_name" {
  type        = string
  description = "Name of the Image Builder pipeline"
}

variable "description" {
  type        = string
  description = "Description of the Image Builder pipeline"
  default     = null
}

variable "image_name" {
  type        = string
  description = "Name prefix given to the AMI created by the pipeline"
}

variable "image_recipe_arn" {
  type        = string
  description = "ARN of the image recipe to use"
}

# Network configuration
variable "vpc_id" {
  type        = string
  description = "VPC ID where the pipeline will run"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the pipeline will run"
}

variable "security_groups" {
  type        = list(string)
  description = "Security group IDs for the image builder"
  default     = []
}

# Instance configuration
variable "instance_types" {
  type        = list(string)
  description = "List of EC2 instance types to use for building"
  default     = ["t3.medium"]
}

# Testing configuration
variable "image_tests_enabled" {
  type        = bool
  description = "Whether to run tests during image creation"
  default     = true
}

variable "image_tests_timeout_minutes" {
  type        = number
  description = "Maximum time allowed for image tests to run"
  default     = 60
}

# Distribution configuration
variable "kms_key_id" {
  type        = string
  description = "KMS key ID used to encrypt the distributed AMI"
  default     = null
}

variable "regions" {
  type        = list(string)
  description = "Regions that the AMIs will be available in"
  default     = ["ap-southeast-1"]
}

variable "organization_arn" {
  type        = string
  description = "AWS Organization ARN to share images with"
  default     = null
}

# Schedule configuration
variable "schedule_cron" {
  type        = string
  description = "Schedule in cron for the pipeline to run automatically"
  default     = null
}

variable "schedule_tz" {
  type        = string
  description = "Timezone (in IANA format) that scheduled builds run"
  default     = "UTC"
}

# Notification configuration
variable "sns_topic_arn" {
  type        = string
  description = "SNS topic to notify when new images are created"
  default     = null
}

# Tags
variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}

# Logging configuration
variable "logging_bucket" {
  type        = string
  description = "S3 bucket to store Image Builder logs"
  default     = null
}

variable "logging_prefix" {
  type        = string
  description = "S3 bucket prefix for Image Builder logs"
  default     = "image-builder/logs/"
}
