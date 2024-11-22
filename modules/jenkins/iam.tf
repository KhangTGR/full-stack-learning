# Master Node IAM Policy
resource "aws_iam_policy" "master_node_policy" {
  name        = "${var.prefix}-${var.environment}-master-policy"
  description = "IAM policy for master node to manage worker nodes"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowJenkinsMasterToGenerateEC2InstancesAsWorkerNodes"
        Effect = "Allow"
        Action = [
          "ec2:DescribeSpotInstanceRequests",
          "ec2:CancelSpotInstanceRequests",
          "ec2:GetConsoleOutput",
          "ec2:RequestSpotInstances",
          "ec2:RunInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeRegions",
          "ec2:DescribeImages",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "iam:ListInstanceProfilesForRole",
          "iam:PassRole",
          "ec2:GetPasswordData"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.prefix}-${var.environment}-master-policy",
    Environment = var.environment
  })
}

# Master Node IAM Role
resource "aws_iam_role" "master_node_role" {
  name = "${var.prefix}-${var.environment}-master-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.prefix}-${var.environment}-master-role",
    Environment = var.environment
  })
}

resource "aws_iam_role_policy_attachment" "master_node_policy_attachment" {
  role       = aws_iam_role.master_node_role.name
  policy_arn = aws_iam_policy.master_node_policy.arn
}

# Master Node Instance Profile
resource "aws_iam_instance_profile" "master_node_instance_profile" {
  name = "${var.prefix}-${var.environment}-master-instance-profile"
  role = aws_iam_role.master_node_role.name

  tags = merge(var.tags, {
    Name        = "${var.prefix}-${var.environment}-master-instance-profile",
    Environment = var.environment
  })
}

# Worker Node IAM Policy
resource "aws_iam_policy" "worker_node_policy" {
  name        = "${var.prefix}-${var.environment}-worker-policy"
  description = "IAM policy for worker nodes"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAccessToCodeArtifact"
        Effect = "Allow"
        Action = [
          "codeartifact:Login",
          "codeartifact:PublishPackageVersion",
          "codeartifact:ReadFromRepository",
          "codeartifact:GetAuthorizationToken",
          "codeartifact:GetRepositoryEndpoint"
        ]
        Resource = "*"
      },
      {
        Sid      = "AllowSTSGetServiceBearerToken"
        Effect   = "Allow",
        Action   = "sts:GetServiceBearerToken",
        Resource = "*",
        Condition = {
          StringEquals = {
            "sts:AWSServiceName" = "codeartifact.amazonaws.com"
          }
        }
      },
      {
        Sid    = "AllowAccessToECR"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowAccessToTaskDefinition"
        Effect = "Allow"
        Action = [
          "ecs:RegisterTaskDefinition"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowCodeDeploy"
        Effect = "Allow"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:StopDeployment"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.prefix}-${var.environment}-worker-policy",
    Environment = var.environment
  })
}

# Worker Node IAM Role
resource "aws_iam_role" "worker_node_role" {
  name = "${var.prefix}-${var.environment}-worker-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.prefix}-${var.environment}-worker-role",
    Environment = var.environment
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policy_attachment" {
  role       = aws_iam_role.worker_node_role.name
  policy_arn = aws_iam_policy.worker_node_policy.arn
}

# Worker Node Instance Profile
resource "aws_iam_instance_profile" "worker_node_instance_profile" {
  name = "${var.prefix}-${var.environment}-worker-instance-profile"
  role = aws_iam_role.worker_node_role.name

  tags = merge(var.tags, {
    Name        = "${var.prefix}-${var.environment}-worker-instance-profile",
    Environment = var.environment
  })
}
