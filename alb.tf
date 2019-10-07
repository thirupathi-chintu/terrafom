# alb.tf

resource "aws_alb" "jenkins" {
  name            = "jenkins-load-balancer"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
  tags = {
    Name = "jenkins_alb"
  }
}

resource "aws_alb_target_group" "jenkins" {
  name        = "jenkins-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.master.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "jenkins" {
  load_balancer_arn = aws_alb.jenkins.id
  port              = var.jenkins_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.jenkins.id
    type             = "forward"
  }
}

