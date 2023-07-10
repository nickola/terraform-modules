variable "name" {
  description = "Name."
  type        = string
}

variable "cidr_block" {
  description = "CIDR block."
  type        = string
}

variable "enable_dns_support" {
  description = "Enable / disable DNS support."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable / disable DNS hostnames."
  type        = bool
  default     = false
}

variable "public_subnets" {
  description = "Public subnets."
  type        = map(any)
  default     = {}
}

variable "private_subnets" {
  description = "Private subnets."
  type        = map(any)
  default     = {}
}
