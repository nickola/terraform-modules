variable "bucket" {
  description = "Bucket name."
  type        = string
}

variable "public_read" {
  description = "Allow public read."
  type        = bool
  default     = false
}

# Policy
variable "policy" {
  description = "Bucket policy."
  type        = list(any)
  default     = null
}

# Content
variable "content_directory" {
  description = "Content directory."
  type        = string
  default     = null
}

variable "content_directory_exclude" {
  description = "Content directory exclude."
  type        = list(string)
  default     = null
}

variable "content_directory_exclude_always" {
  description = "Content directory exclude (always)."
  type        = list(string)
  default     = ["**/.DS_Store", "**/.git*", "**/*.env", "**/Makefile", "**/*.code-workspace", "**/.venv", "**/__pycache__", "**/*.pyc"]
}

# Website
variable "website_redirect" {
  description = "Website redirect."
  type        = string
  default     = null
}

variable "website_redirect_protocol" {
  description = "Website redirect protocol."
  type        = string
  default     = "https"
}
