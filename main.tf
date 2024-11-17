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
  prefix      = var.prefix
  environment = var.environment

  # Load Balancer
  alb_blue_target_group_name  = "khang-sample-app-tg"
  alb_green_target_group_name = "khang-sample-app-tg-2nd"
  alb_prod_listener_arns      = ["arn:aws:elasticloadbalancing:ap-southeast-1:879654127886:listener/app/khang-sample-app-alb/95ad5c51b27e5e8b/6e48bb4a45453534"]
  alb_test_listener_arns      = []

  # Container
  container_name = "khang-sample-app"
  container_port = "5000"

  # ECS
  ecs_cluster_name = module.cluster.cluster_name
  ecs_service_name = "khang-sample-app-service"
  ecs_task_def_arn = "arn:aws:ecs:ap-southeast-1:879654127886:task-definition/khang-sample-app-taskdef:7"

  # Others
  old_tasks_termination_wait_time = 5
}
