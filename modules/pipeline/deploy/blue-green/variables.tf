variable "prefix" {
  description = "Prefix for resource names"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
}

variable "ecs_cluster_name" {
  type        = string
  description = "ECS Cluster name"
}

variable "ecs_service_name" {
  type        = string
  description = "ECS Service name"
}

variable "ecs_task_def_arn" {
  type        = string
  description = "ECS Task definition Arn"
}

variable "container_name" {
  type        = string
  description = "Container name"
}

variable "container_port" {
  type        = number
  description = "Container port"
}

variable "deployment_config_name" {
  type        = string
  description = "CodeDeploy Deployment Config name"
  default     = "CodeDeployDefault.ECSAllAtOnce"
}

variable "old_tasks_termination_wait_time" {
  type        = number
  description = "Old ECS task termination wait time in minutes"
}

variable "alb_prod_listener_arns" {
  type        = list(string)
  description = "List of Arns of ALB Pod listners"
}

variable "alb_test_listener_arns" {
  type        = list(string)
  description = "List of Arns of ALB Test listners"
}

variable "alb_blue_target_group_name" {
  type        = string
  description = "ALB Blue target group name"
}

variable "alb_green_target_group_name" {
  type        = string
  description = "ALB Green target group name"
}
