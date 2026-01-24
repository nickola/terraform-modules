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

variable "default_content_type" {
  type        = string
  description = "Default content type."
  default     = "application/octet-stream"
}

variable "content_types" {
  description = "Content types."
  type        = map(string)
  default = {
    ".txt"    = "text/plain; charset=utf-8"
    ".html"   = "text/html; charset=utf-8"
    ".htm"    = "text/html; charset=utf-8"
    ".xhtml"  = "application/xhtml+xml"
    ".css"    = "text/css; charset=utf-8"
    ".js"     = "application/javascript"
    ".xml"    = "application/xml"
    ".json"   = "application/json"
    ".jsonld" = "application/ld+json"
    ".gif"    = "image/gif"
    ".jpeg"   = "image/jpeg"
    ".jpg"    = "image/jpeg"
    ".png"    = "image/png"
    ".svg"    = "image/svg+xml"
    ".webp"   = "image/webp"
    ".weba"   = "audio/webm"
    ".webm"   = "video/webm"
    ".3gp"    = "video/3gpp"
    ".3g2"    = "video/3gpp2"
    ".pdf"    = "application/pdf"
    ".swf"    = "application/x-shockwave-flash"
    ".atom"   = "application/atom+xml"
    ".rss"    = "application/rss+xml"
    ".ico"    = "image/vnd.microsoft.icon"
    ".jar"    = "application/java-archive"
    ".ttf"    = "font/ttf"
    ".otf"    = "font/otf"
    ".eot"    = "application/vnd.ms-fontobject"
    ".woff"   = "font/woff"
    ".woff2"  = "font/woff2"
  }
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
