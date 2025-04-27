variable "component_name" {
  type        = string
  description = "Name of the component"
}

variable "description" {
  type        = string
  description = "Description of the component"
  default     = "Shell command component for Image Builder"
}

variable "platform" {
  type        = string
  description = "Platform for the component (Linux or Windows)"
  validation {
    condition     = contains(["Linux", "Windows"], var.platform)
    error_message = "Platform must be either 'Linux' or 'Windows'."
  }
}

variable "component_version" {
  type        = string
  description = "Version of the component"
  default     = "1.0.0"
}

variable "commands" {
  type        = list(string)
  description = "List of shell commands to execute"
}

variable "on_failure" {
  type        = string
  description = "Action to take on command failure"
  default     = "Continue"
  validation {
    condition     = contains(["Continue", "Abort"], var.on_failure)
    error_message = "on_failure must be either 'Continue' or 'Abort'."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the component"
  default     = {}
}

variable "phase" {
  type        = string
  description = "Phase in which to run the commands (build, validate, or test)"
  default     = "build"
  validation {
    condition     = contains(["build", "validate", "test"], var.phase)
    error_message = "Phase must be one of: build, validate, or test."
  }
}
