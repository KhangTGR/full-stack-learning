resource "aws_ecs_cluster" "cluster" {
  name = "${var.prefix}-${var.environment}-${var.cluster_name}"

  setting {
    name  = "containerInsights"
    value = var.container_insights_configuration
  }

  tags = merge(var.tags, {
    Name        = "${var.prefix}-${var.environment}-${var.cluster_name}"
    Environment = "${var.environment}"
  })
}
