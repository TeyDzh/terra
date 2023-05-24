provider "aws" {
  region     = "eu-central-1"
  profile    = "main"
}

resource "aws_vpc" "ecs_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  
  tags = {
    Name = "private-subnet"
  }
}

resource "aws_ecs_cluster" "main_cluster" {
  name = "main-cluster"
}

resource "aws_lb" "alb" {
  name               = "alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet.id]

  tags = {
    Name = "alb"
  }
}

resource "aws_ecs_task_definition" "task" {
  family                = "task"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  
  container_definitions = <<DEFINITION
  [
    {
      "name": "ДОДАТИ",
      "image": "ДОДАТИ",
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ],
      "cpu": 256,
      "memory": 512
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "service" {
  name            = "service"
  cluster         = "main-cluster"
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "container"
    container_port   = 80
  }
}

resource "aws_lb_target_group" "target_group" {
  name     = "target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ecs_vpc.id

  health_check {
    path = "/"
    port = 80
  }
}

# resource "aws_route53_zone" "zone" {
#   name = "domain.com"
# }

# resource "aws_route53_record" "my_record" {
#   zone_id = aws_route53_zone.zone.zone_id
#   name    = "domain.com"
#   type    = "A"
#   ttl     = "300"
#   records = [aws_lb.my_alb.dns_name]
# }
