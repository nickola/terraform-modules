variable "name" {
  description = "Name."
  type        = string
}

variable "domain" {
  description = "Domain."
  type        = string
  default     = null
}

variable "redirect" {
  description = "Redirect URL."
  type        = string
  default     = null
}

variable "redirect_as_function" {
  description = "Redirect as function."
  type        = string
  default     = false
}

variable "redirect_protocol" {
  description = "Redirect protocol."
  type        = string
  default     = "https"
}

# Content
variable "content_directory" {
  description = "Content directory (S3 files)."
  type        = string
  default     = null
}

# HTML files
variable "index_file" {
  description = "Index file."
  type        = string
  default     = null
}

variable "index_html" {
  description = "Index file content."
  type        = string
  default     = null
}

variable "error_file" {
  description = "Error (404) file."
  type        = string
  default     = null
}

variable "error_html" {
  description = "Error (404) file content."
  type        = string
  default     = null
}

# CloudFront
variable "price_class" {
  description = "Price class."
  type        = string
  default     = "PriceClass_100"
}

variable "allowed_methods" {
  description = "Allowed methods."
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "cached_methods" {
  description = "Cached methods."
  type        = list(string)
  default     = null
}

variable "geo_restriction" {
  description = "Geo restriction."
  type        = list(string)
  default     = null
}

# TTL
variable "ttl" {
  description = "TTL."
  type        = number
  default     = 0
}

variable "ttl_min" {
  description = "Minimum TTL."
  type        = number
  default     = null
}

variable "ttl_max" {
  description = "Maximum TTL."
  type        = number
  default     = null
}

# Rules
variable "rules" {
  description = "Rules."
  type = list(object({
    url               = string,
    lambda_url        = string,
    forwarded_headers = optional(list(string)),
    allowed_methods   = optional(list(string)),
    cached_methods    = optional(list(string)),
    ttl               = optional(number),
    ttl_min           = optional(number),
    ttl_max           = optional(number)
  }))
  default = null
}
