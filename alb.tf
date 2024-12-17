resource "aws_lb" "minio_alb" {
  name               = "minio-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.docker_sg.id]
  subnets            = [aws_subnet.docker_subnet.id]
}

resource "aws_lb_target_group" "minio_tg" {
  name     = "minio-tg"
  port     = 9000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_docker.id
}

resource "aws_lb_listener" "minio_listener" {
  load_balancer_arn = aws_lb.minio_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.minio_tg.arn
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.minio_asg.name
  lb_target_group_arn    = aws_lb_target_group.minio_tg.arn
}
