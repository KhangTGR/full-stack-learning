# Terraform Modules for AWS CodePipeline and ECS Blue/Green Deployment

This project contains Terraform modules designed to set up an AWS ECS cluster with Blue/Green deployment via AWS CodeDeploy, and to create necessary infrastructure components such as EC2 capacity providers, ECS clusters, and deployment pipelines.

### Modules Included:
- **`ecs/cluster`**: Creates an ECS cluster.
- **`ecs/provider`**: Creates an EC2 capacity provider for the ECS cluster (EC2 template and auto-scaling group).
- **`pipeline/deploy/blue-green`**: Creates a Blue/Green deployment for ECS using AWS CodeDeploy.

---

## Steps for Usage

### 1. Create ECS Cluster

This step involves setting up an ECS cluster, which will serve as the target environment for ECS tasks.

**Example:**

```hcl
module "cluster" {
  source = "./modules/ecs/cluster"

  # Naming
  prefix      = var.prefix
  environment = var.environment

  # Configuration
  cluster_name     = var.cluster_name
  container_insights_configuration = var.container_insights_configuration

  # Tags
  tags = {
    "Owner"      = "khang.nguyen"
    "Managed by" = "Terraform"
  }
}
```

**Usage:**
```bash
terraform apply
```

For more details on ECS clusters, refer to the [AWS ECS Cluster documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Clusters.html) and Terraform AWS resources [[1]](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service).

### 2. Create EC2 Capacity Provider for ECS

To provision EC2 instances to run ECS tasks, this step sets up an EC2 capacity provider, which automates the management of EC2 instances as part of the ECS cluster.

**Example:**

```hcl
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
```

**Usage:**
```bash
terraform apply
```

For more information on ECS Capacity Providers, see the [AWS ECS Capacity Provider documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/CapacityProvider.html), and Terraform AWS resources [[2]](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_capacity_provider)[[3]](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers).

### 3. Create Application Load Balancer (ALB) with Two Target Groups

**Manually** create an Application Load Balancer (ALB) with two target groups:
- One target group for the Blue environment.
- One target group for the Green environment.

The ALB will be used to route traffic between the two environments in a Blue/Green deployment.

For more information on how to create an ALB, refer to [AWS ALB documentation](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html).

### 4. Create ECS Task Definition and ECS Service with Blue/Green Configuration

**Manually** create an ECS task definition and ECS service. Ensure that the ECS service is configured for Blue/Green deployment by using an application load balancer and defining the appropriate listener rules for Blue and Green traffic routing.

For detailed guidance on how to create ECS services, refer to the [AWS ECS Service documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/what-is-fargate.html).

### 5. Set Up Blue/Green Deployment via AWS CodeDeploy

This module configures AWS CodeDeploy to handle Blue/Green deployment for the ECS service. CodeDeploy manages the traffic shifting between the Blue and Green environments.

**Example:**

```hcl
module "deployment" {
  source = "./modules/pipeline/deploy/blue-green"

  # Naming
  prefix      = var.prefix
  environment = var.environment

  # Load Balancer
  alb_blue_target_group_name  = var.alb_blue_target_group_name
  alb_green_target_group_name = var.alb_green_target_group_name
  alb_prod_listener_arns      = var.alb_prod_listener_arns
  alb_test_listener_arns      = var.alb_test_listener_arns

  # Container
  container_name = "khang-sample-app"
  container_port = "5000"

  # ECS
  ecs_cluster_name = module.cluster.cluster_name
  ecs_service_name = var.ecs_service_name
  ecs_task_def_arn = var.ecs_task_def_arn

  # Others
  old_tasks_termination_wait_time = 5

  depends_on = [module.capacity_provider]

  # Tags
  tags = {
    "Owner"      = "khang.nguyen"
    "Managed by" = "Terraform"
  }
}
```

**Usage:**
```bash
terraform apply
```

For more details on how AWS CodeDeploy Blue/Green deployments work with ECS, check out the [AWS CodeDeploy Blue/Green documentation](https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-configurations.html).

---

### Additional Resources:
- [AWS ECS Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)
- [AWS CodeDeploy Blue/Green Deployments](https://docs.aws.amazon.com/codedeploy/latest/userguide/deployment-pipeline.html)
- [AWS EC2 Capacity Provider Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/CapacityProvider.html)

By following these steps, you can set up an ECS cluster and manage Blue/Green deployments using CodeDeploy to ensure seamless updates and minimal downtime.
