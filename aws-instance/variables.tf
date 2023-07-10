variable "name" {
  description = "Name."
  type        = string
}

variable "instances" {
  description = "Instances."
  type        = map(any)
}
