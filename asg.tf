resource "aws_launch_template" "minio_lt" {
  name_prefix   = "minio-lt-"
  image_id      = "ami-061dd8b45bc7deb3d" # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = "vockey"

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum install -y docker
              sudo systemctl start docker
              sudo usermod -aG docker ec2-user
              docker run -dp 9000:9000 -p 9001:9001 --name minio \
                -e MINIO_ROOT_USER="admin" \
                -e MINIO_ROOT_PASSWORD="password" \
                minio/minio server /data --console-address ":9001"
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "minio-instance" }
  }
}

resource "aws_autoscaling_group" "minio_asg" {
  name                      = "minio-asg"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = [
    aws_subnet.docker_subnet.id,
    aws_subnet.docker_subnet_2.id
  ]
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
