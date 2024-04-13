variable "name" {
  description = "Name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "domain" {
  description = "Domain."
  type        = string
}

variable "description" {
  description = "Description."
  type        = string
  default     = ""
}

variable "services" {
  description = "Services."
  type        = list(string)
}
