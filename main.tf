module "cluster" {
  source = "./modules/ecs/cluster"

  # Naming
  prefix      = var.prefix
  environment = var.environment

  # Configuration
  cluster_name                     = var.cluster_name
  container_insights_configuration = var.container_insights_configuration

  # Tags
  tags = {
    "Owner"      = "khang.nguyen"
    "Managed by" = "Terraform"
  }
}

module "capacity_provider" {
  source = "./modules/ecs/provider"

  # Naming
  prefix       = var.prefix
  environment  = var.environment
  cluster_name = module.cluster.cluster_name

  # Compute
  instance_type = var.instance_type
  keypair       = var.keypair

  # Networking
  asg_subnet_ids              = var.asg_subnet_ids
  instance_security_group_ids = var.instance_security_group_ids

  # Tags
  tags = {
    "Owner"      = "khang.nguyen"
    "Managed by" = "Terraform"
  }
}

module "deployment" {
  source = "./modules/pipeline/deploy/blue-green"

  # Naming
  prefix       = var.prefix
  environment  = var.environment

  # Load Balancer
  alb_blue_target_group_name = ""
  alb_green_target_group_name = ""
  alb_prod_listener_arns = ""
  alb_test_listener_arns = ""

  # Container
  container_name = ""
  container_port = ""

  # ECS
  ecs_cluster_name = module.cluster.cluster_name
  ecs_service_name = ""
  ecs_task_def_arn = ""

  # Others
  old_tasks_termination_wait_time = 300
}
