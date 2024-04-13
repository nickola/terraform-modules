# CloudFront
variable "description" {
  description = "Description."
  type        = string
  default     = null
}

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
  default     = ["GET", "HEAD", "OPTIONS"]
}

variable "geo_restriction" {
  description = "Geo restriction."
  type        = list(string)
  default     = null
}

# S3
variable "s3_bucket_id" {
  description = "S3 bucket ID."
  type        = string
  default     = ""
}

variable "s3_bucket_create_policy" {
  description = "Create S3 bucket policy for CloudFront."
  type        = bool
  default     = false
}

variable "domain_alias" {
  description = "Alias domain name."
  type        = string
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

# HTML files
variable "index_file" {
  description = "Index file."
  type        = string
  default     = "_index.html"
}

variable "index_html" {
  description = "Index file content."
  type        = string
  default     = ""
}

variable "error_file" {
  description = "Error (404) file."
  type        = string
  default     = "_404.html"
}

variable "error_html" {
  description = "Error (404) file content."
  type        = string
  default     = ""
}

# Rules
variable "rules" {
  description = "Rules."
  type = list(object({
    url             = string,
    lambda_url      = string,
    allowed_methods = optional(list(string)),
    cached_methods  = optional(list(string)),
    ttl             = optional(number),
    ttl_min         = optional(number),
    ttl_max         = optional(number)
  }))
  default = null
}
