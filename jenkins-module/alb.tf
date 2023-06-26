resource "aws_alb" "application_load_balancer" {
  name               = "${var.app_name}-alb"
  load_balancer_type = "application"
  internal           = var.alb_internal
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.load_balancer_security_group.id]

  tags = {
    Name = "${var.app_name}-alb"
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.app_name}-tg"
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = aws_vpc.main.id
  target_type = var.target_type

  health_check {
    healthy_threshold   = var.target_group_health_check_healthy_threshold
    interval            = var.target_group_health_check_interval
    protocol            = var.target_group_health_check_protocol
    timeout             = var.target_group_health_check_timeout
    path                = var.target_group_health_check_path
    unhealthy_threshold = var.target_group_health_check_unhealthy_threshold
  }

  tags = {
    Name = "${var.app_name}-lb-tg"
  }
}

resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "${var.app_name}-sg"
  }
}


resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.id
  }
}
