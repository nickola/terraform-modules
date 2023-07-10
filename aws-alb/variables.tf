variable "name" {
  description = "Name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs."
  type        = list(string)
}

variable "internal" {
  description = "Is internal."
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Health check path."
  type        = string
  default     = "/"
}

variable "ingress" {
  description = "Ingress rules."
  type        = list(any)
}
