# iam.tf | IAM ROLE POLICIES

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.app_name}-execution-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = {
    name = "${var.app_name}-iam-role"
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# ECS-cluster

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.app_name}-cluster"
  tags = {
    name = "${var.app_name}-ecs"
  }
}

resource "aws_ecs_task_definition" "aws-ecs-task" {
  family = "${var.app_name}-task"

  # container_definitions = <<DEFINITION
  # [
  #  {
  #    "name": "${var.app_name}-container",
  #    "image": "${aws_ecr_repository.aws-ecr.repository_url}:latest",
  #    "entryPoint": [],
  #    "essential": true,
  #    },
  #    "portMappings": [
  #      {
  #        "containerPort": 8080,
  #        "hostPort": 8080
  #      }
  #    ],
  #    "cpu": 256,
  #    "memory": 512,
  #    "networkMode": "main"
  #  }
  # ]
  # DEFINITION

  requiresrequires_compatibilities = ["FARGATE"]
  network_mode                     = "main"
  memory                           = "512"
  cpu                              = "256"
  execution_role_arn               = aws_iam_role.ecsTaskExecutionRole
  task_role_arn                    = aws_iam_role.ecsTaskExecutionRole

  tags = {
    Name = "${var.app_name}-ecs-td"
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.aws-ecs-task.family
}

resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "${var.app_name}-ecs-service"
  cluster              = aws_ecs_cluster.ecs-cluster.id
  task_definition      = "${aws_ecs_task_definition.aws-ecs-task.family}:${max(aws_ecs_task_definition.aws-ecs-task.revision, data.aws_ecs_task_definition.main.revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_arn
    container_name   = "${var.app_name}-container"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.listener]
}

resource "aws_security_group" "service_security_group" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.app_name}-service-sg"
  }
}
