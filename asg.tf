resource "aws_autoscaling_group" "minio_asg" {
  name                      = "minio-asg"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_subnet.docker_subnet.id]
  launch_template {
    id      = aws_launch_template.minio_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "minio-instance"
    propagate_at_launch = true
  }
}
