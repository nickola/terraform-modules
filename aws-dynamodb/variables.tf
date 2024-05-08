# DynamoDB
variable "name" {
  description = "Name."
  type        = string
}

variable "billing_mode" {
  description = "Billing mode."
  type        = string
  default     = "PROVISIONED"
}

variable "read_capacity" {
  description = "Read capacity."
  type        = number
  default     = 20
}

variable "write_capacity" {
  description = "Write capacity."
  type        = number
  default     = 20
}

variable "hash_key" {
  description = "Hash key."
  type        = string
  default     = "id"
}

variable "hash_key_type" {
  description = "Hash key type."
  type        = string
  default     = "S"
}
