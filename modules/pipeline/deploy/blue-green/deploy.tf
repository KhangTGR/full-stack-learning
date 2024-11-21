resource "aws_codedeploy_app" "this" {
  compute_platform = "ECS"
  name             = local.codedeploy_application_name

  tags = merge(var.tags, {
    Name        = "${local.codedeploy_application_name}"
    Environment = "${var.environment}"
  })
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_config_name = var.deployment_config_name
  deployment_group_name  = local.deployment_group_name
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.old_tasks_termination_wait_time
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = var.alb_prod_listener_arns
      }

      test_traffic_route {
        listener_arns = var.alb_test_listener_arns
      }

      target_group {
        name = var.alb_blue_target_group_name
      }

      target_group {
        name = var.alb_green_target_group_name
      }
    }

  }

  lifecycle {
    ignore_changes = [blue_green_deployment_config, load_balancer_info[0].target_group_pair_info[0].test_traffic_route]
  }

  tags = merge(var.tags, {
    Name        = "${local.deployment_group_name}"
    Environment = "${var.environment}"
  })
}
