variable "name" {
  description = "Name."
  type        = string
}

variable "virtual_nodes" {
  description = "Virtual nodes."
  type        = map(any)
}

variable "virtual_services" {
  description = "Virtual services."
  type        = map(any)
}

variable "egress_filter" {
  description = "Egress filter."
  type        = string
  default     = "ALLOW_ALL"
}
