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

variable "source_directory_excludes" {
  description = "Source directory excludes."
  type        = list(string)
  default     = [".git", ".gitignore", ".gitmodules", ".venv"]
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
