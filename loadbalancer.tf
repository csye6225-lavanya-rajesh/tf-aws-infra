
resource "aws_lb" "webapp_alb" {
  name               = "webapp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.loadbalancer_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "webapp-alb"
  }
}

resource "aws_lb_target_group" "webapp_target_group" {
  name                 = "webapp-target-group"
  port                 = var.app_port
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  deregistration_delay = 30

  health_check {
    protocol            = "HTTP"
    path                = "/healthz"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "webapp-target-group"
  }
}

data "aws_acm_certificate" "dev_cert" {
  domain      = var.aws_profile == "dev" ? "dev.lavanyarajesh.me" : "demo.lavanyarajesh.me"
  most_recent = true
}


# HTTPS listener with existing certificate
resource "aws_lb_listener" "dev_https" {
  load_balancer_arn = aws_lb.webapp_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.aws_profile == "dev" ? data.aws_acm_certificate.dev_cert.arn : var.demo_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_target_group.arn
  }
}

# resource "aws_lb_listener" "webapp_listener" {
#   load_balancer_arn = aws_lb.webapp_alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.webapp_target_group.arn
#   }
# }

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  lb_target_group_arn    = aws_lb_target_group.webapp_target_group.arn
}