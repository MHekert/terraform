resource "aws_lb" "alb" {
  internal           = false
  load_balancer_type = "application"
  name               = "${var.project}-${var.env}-alb"
  subnets            = [aws_subnet.main.id, aws_subnet.secondary.id]
}

resource "aws_lb_target_group" "alb_target_group" {
  name_prefix = "lb-tg-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    interval            = "10"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    path                = "/health"
    matcher             = "200"
  }
}

resource "aws_lb_listener" "alb_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.id
  }
}
