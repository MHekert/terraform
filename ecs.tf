resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project}-${var.env}-cluster"
}

resource "aws_autoscaling_group" "asc_group" {
  max_size            = var.asc_max_size
  min_size            = var.asc_min_size
  vpc_zone_identifier = [aws_subnet.main.id]

  launch_configuration = aws_launch_configuration.launch_config.name

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "${var.project}-${var.env}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.asc_group.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 10
    }
  }
}


resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "${var.project}-${var.env}"
  requires_compatibilities = ["EC2"]
  memory                   = var.task_memory
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "${var.app_container_name}",
    "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/${aws_ecr_repository.ecr_repo.name}:latest",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "EXAMPLE_SECRET",
        "value": "${var.EXAMPLE_SECRET}"
      }
    ]
  }
]
TASK_DEFINITION
}

resource "aws_ecs_service" "ecs_service" {
  name                              = "${var.project}-${var.env}-ecs-service"
  cluster                           = aws_ecs_cluster.ecs_cluster.arn
  desired_count                     = var.desired_count
  launch_type                       = "EC2"
  task_definition                   = aws_ecs_task_definition.ecs_task_definition.arn
  health_check_grace_period_seconds = 60

  ordered_placement_strategy {
    field = "instanceId"
    type  = "spread"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    container_name   = var.app_container_name
    container_port   = var.app_port
  }
}
