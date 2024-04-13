variable "bucket" {
  description = "Bucket name."
  type        = string
}

variable "public_read" {
  description = "Allow public read."
  type        = bool
  default     = false
}
