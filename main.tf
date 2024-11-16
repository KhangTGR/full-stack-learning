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
  source = "./modules/ecs/capacity_provider"

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
