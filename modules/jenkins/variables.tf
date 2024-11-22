variable "prefix" {
  description = "Prefix for resource names"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
