variable "prefix" {
  description = "Prefix for resource names"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
}

variable "cluster_name" {
  description = "ECS cluster name"
}

variable "container_insights_configuration" {
  description = "Enable container insights for ECS cluster"
  type        = string
  default     = "enabled"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
