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

variable "architecture" {
  description = "Architecture."
  type        = string
  default     = "x86_64"
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

variable "log_retention" {
  description = "Lambda log retention (days)."
  type        = number
  default     = 30
}

variable "policy" {
  description = "Lambda role policy."
  type        = string
  default     = null
}

variable "policy_attachments" {
  description = "Lambda role policy attachments (example: arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole)."
  type        = list(string)
  default     = null
}
