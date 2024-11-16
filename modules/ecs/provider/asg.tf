resource "aws_autoscaling_group" "ecs_asg" {
  name = "${local.name}-ecs-asg"

  desired_capacity = 0
  min_size         = 0
  max_size         = 2

  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupInServiceCapacity", "GroupPendingInstances", "GroupPendingCapacity", "GroupTerminatingInstances", "GroupTerminatingCapacity", "GroupStandbyInstances", "GroupStandbyCapacity", "GroupTotalInstances", "GroupTotalCapacity", "WarmPoolMinSize", "WarmPoolDesiredCapacity", "WarmPoolPendingCapacity", "WarmPoolTerminatingCapacity", "WarmPoolWarmedCapacity", "WarmPoolTotalCapacity", "GroupAndWarmPoolDesiredCapacity", "GroupAndWarmPoolTotalCapacity"]

  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Default"
  }

  vpc_zone_identifier = var.asg_subnet_ids

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}
