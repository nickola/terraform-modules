variable "domain" {
  description = "Domain."
  type        = string
}

variable "records" {
  description = "Records."
  type = list(object({
    name   = optional(string)
    type   = string
    ttl    = number
    values = list(string)
  }))
  default = null
}
