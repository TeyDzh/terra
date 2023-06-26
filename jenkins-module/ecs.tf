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
  family                   = "${var.app_name}-task"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  container_definitions = <<DEFINITION
  [
   {
     "name": "${var.app_name}-container",
     "image": "jenkins/jenkins:lts",
     "entryPoint": [],
     "essential": true,
     "portMappings": [
       {
         "containerPort": ${var.container_port},
         "hostPort": ${var.container_port},
         "protocol" : "tcp"
       }
     ],
     "cpu": ${var.task_cpu},
     "memory": ${var.task_memory},
     "networkMode": "awsvpc"
   }
  ]
  DEFINITION

  tags = {
    Name = "${var.app_name}-ecs-td"
  }
}

resource "aws_ecs_service" "aws-ecs-service" {
  name                 = "${var.app_name}-ecs-service"
  cluster              = aws_ecs_cluster.ecs-cluster.id
  task_definition      = aws_ecs_task_definition.aws-ecs-task.family
  launch_type          = "FARGATE"
  desired_count        = var.count
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
    container_port   = var.container_port
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
