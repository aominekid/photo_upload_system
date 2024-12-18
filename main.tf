terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.55.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"  # Stelle sicher, dass die Region passt
}

# VPC erstellen
resource "aws_vpc" "vpc_docker" {
  cidr_block = "10.0.0.0/27"
  tags = { Name = "vpc-docker" }
}

# Subnet 1 erstellen
resource "aws_subnet" "docker_subnet" {
  vpc_id                  = aws_vpc.vpc_docker.id
  cidr_block              = "10.0.0.0/28"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
  tags = { Name = "docker-subnet" }
}

# Subnet 2 erstellen
resource "aws_subnet" "docker_subnet_2" {
  vpc_id                  = aws_vpc.vpc_docker.id
  cidr_block              = "10.0.2.0/28" # Neuer IP-Bereich
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
  tags = { Name = "docker-subnet-2" }
}

# Internet Gateway erstellen
resource "aws_internet_gateway" "igw_docker" {
  vpc_id = aws_vpc.vpc_docker.id
  tags = { Name = "igw-docker" }
}

# Route Table erstellen
resource "aws_route_table" "rt_docker" {
  vpc_id = aws_vpc.vpc_docker.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_docker.id
  }

  tags = { Name = "docker-route-table" }
}

# Route Table mit Subnets verknüpfen
resource "aws_route_table_association" "rta_docker" {
  subnet_id      = aws_subnet.docker_subnet.id
  route_table_id = aws_route_table.rt_docker.id
}

resource "aws_route_table_association" "rta_docker_2" {
  subnet_id      = aws_subnet.docker_subnet_2.id
  route_table_id = aws_route_table.rt_docker.id
}

# Security Group erstellen
resource "aws_security_group" "docker_sg" {
  vpc_id = aws_vpc.vpc_docker.id
  tags = { Name = "docker-sg" }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9001
    to_port     = 9001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
