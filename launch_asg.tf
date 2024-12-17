resource "aws_launch_template" "minio_lt" {
  name_prefix   = "minio-lt-"
  image_id      = "ami-061dd8b45bc7deb3d" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = "vockey" # Dein Key-Pair

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum install -y docker
              sudo systemctl start docker
              sudo usermod -aG docker ec2-user
              docker run -dp 9000:9000 -p 9001:9001 --name minio \
                -e "MINIO_ROOT_USER=admin" \
                -e "MINIO_ROOT_PASSWORD=password" \
                minio/minio server /data --console-address ":9001"
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "minio-instance"
    }
  }
}
