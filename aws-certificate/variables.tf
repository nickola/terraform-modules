variable "domain" {
  description = "Domain."
  type        = string
}

variable "validation_method" {
  description = "Validation method."
  type        = string
  default     = "DNS"
}
