resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "${local.name}-ec2-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 75
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 4
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name = var.cluster_name

  capacity_providers = [
    aws_ecs_capacity_provider.ecs_capacity_provider.name
  ]
}
