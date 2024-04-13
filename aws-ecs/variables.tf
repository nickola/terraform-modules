variable "name" {
  description = "Name."
  type        = string
}

variable "container_insights" {
  description = "Enable Container Insights."
  type        = bool
  default     = false
}

variable "task_definitions" {
  description = "Task definitions."
  type        = map(any)
  default     = {}
}

variable "services" {
  description = "Services."
  type        = map(any)
  default     = {}
}
