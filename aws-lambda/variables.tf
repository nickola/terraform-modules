variable "name" {
  description = "Name."
  type        = string
}

variable "runtime" {
  description = "Runtime."
  type        = string
}

variable "handler" {
  description = "Handler."
  type        = string
}

variable "memory" {
  description = "Memory (MB)."
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout (seconds)."
  type        = number
  default     = 3
}

variable "source_file" {
  description = "Source file."
  type        = string
  default     = null
}

variable "source_directory" {
  description = "Source directory."
  type        = string
  default     = null
}

variable "source_directory_excludes_always" {
  description = "Source directory excludes (always)."
  type        = list(string)
  default     = ["**/.git*", "**/*.env", "**/Makefile", "**/*.code-workspace", "**/.venv", "**/__pycache__", "**/*.pyc"]
}

variable "source_directory_excludes" {
  description = "Source directory excludes."
  type        = list(string)
  default     = null
}

variable "environment" {
  description = "Environment variables."
  type        = map(string)
  default     = null
}

variable "url_enabled" {
  description = "Enable Lambda function URL."
  type        = bool
  default     = false
}

variable "policy" {
  description = "Lambda role policy."
  type        = string
  default     = null
}
