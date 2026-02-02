variable "name" {
  description = "Budget name."
  type        = string
}

variable "type" {
  description = "Budget type."
  type        = string
  default     = "COST"
}

variable "time" {
  description = "Budget time."
  type        = string
  default     = "MONTHLY"
}

variable "limit_unit" {
  description = "Budget limit unit."
  type        = string
  default     = "USD"
}

variable "limit" {
  description = "Budget limit."
  type        = number
}

variable "emails" {
  description = "Alert emails."
  type        = list(string)
}

# Preliminary alert
variable "preliminary_alert" {
  description = "Preliminary alert enabled."
  type        = bool
  default     = true
}

variable "preliminary_alert_percent" {
  description = "Preliminary alert percent."
  type        = number
  default     = 85
}
