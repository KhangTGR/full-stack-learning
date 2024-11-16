variable "prefix" {
  description = "Prefix for resource names"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
}

variable "instance_type" {
  description = "Instance type for the ECS capacity provider"
  default     = "t3.micro"
}

variable "cluster_name" {
  description = "ECS cluster name"
}

variable "keypair" {
  description = "Key pair name for SSH access to instances"
}

variable "instance_security_group_ids" {
  description = "List of security group IDs to assign to the ECS instances"
  type        = list(string)
}

variable "asg_subnet_ids" {
  description = "List of subnet IDs for the auto-scaling group"
  type        = list(string)
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
