variable "name" {
  description = "Name."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "ingress" {
  description = "Ingress rules."
  type        = list(any)
  default     = null
}

variable "egress_all" {
  description = "Egress rules (allow all)."
  type        = bool
  default     = true
}
