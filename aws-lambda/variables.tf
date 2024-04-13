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
}

variable "url_enabled" {
  description = "Enable Lambda function URL."
  type        = bool
  default     = false
}
