# Configure AWS provider
provider "aws" {
  region = "eu-west-1"
}

# Look up existing SGs by name
data "aws_security_group" "controller_sg" {
  name = "tech515-carla-controller-sg"
}

data "aws_security_group" "target_node_app_sg" {
  name = "tech515-carla-target-node-app-allow-port-22-80-3000"
}


# Networking Security Group
resource "aws_security_group" "target_node_db_sg" {
  name        = "tech515-carla-target-node-db-allow-port-22-27017"
  description = "Allow SSH from controller and MongoDB from app"

  ingress {
    description     = "SSH from the controller_sg"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [data.aws_security_group.controller_sg.id]
  }

  ingress {
    description     = "Port 27017 from target_node_app_sg"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [data.aws_security_group.target_node_app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tech515-carla-target-node-db-allow-port-22-27017"
  }
}

# Compute
# Ubuntu Server 22.04 LTS (free tier eligible)
data "aws_ami" "ubuntu_2204" {
  most_recent = true

  owners = ["099720109477"] # Canonical - OFFICIAL UBUNTU

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "target_node_db" {
  ami           = data.aws_ami.ubuntu_2204.id
  instance_type = "t3.micro"

  associate_public_ip_address = true

  key_name               = "tech515-carla-aws"
  vpc_security_group_ids = [aws_security_group.target_node_db_sg.id]

  tags = {
    Name = "tech515-carla-ubuntu-2204-ansible-target-node-db"
  }
}