locals {
  name = "${var.prefix}-${var.environment}"
}

data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "${local.name}-ecs-instance-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${local.name}-ecs-instance-role"
    Environment = "${var.environment}"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerServiceforEC2Role" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${local.name}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_launch_template" "ecs_launch_template" {
  name = "${local.name}-ecs-lt"

  image_id               = data.aws_ami.ecs_optimized.id
  instance_type          = var.instance_type
  key_name               = var.keypair
  vpc_security_group_ids = var.instance_security_group_ids

  user_data = base64encode(<<EOF
#!/bin/bash
echo "ECS_CLUSTER=${var.cluster_name}" >> /etc/ecs/ecs.config
yum install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.name}-ecs-instance"
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type           = "gp3"
      volume_size           = 30
      delete_on_termination = true
      iops                  = 3000
      throughput            = 125
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_instance_profile.arn
  }

  update_default_version = true

  tags = merge(var.tags, {
    Name        = "${local.name}-ecs-lt"
    Environment = "${var.environment}"
  })
}
