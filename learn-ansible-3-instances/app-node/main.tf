# Configure AWS provider
provider "aws" {
  region = "eu-west-1"
}

# Networking Security Group
resource "aws_security_group" "target_node_app_sg" {
  name        = "tech515-carla-target-node-app-allow-port-22-80-3000"
  description = "Allow SSH, HTTP, port 3000 to app from Anywhere"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Port 3000 from anywhere"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tech515-carla-new-target-node-app-allow-port-22-80-3000"
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

resource "aws_instance" "target_node_app" {
  ami           = data.aws_ami.ubuntu_2204.id
  instance_type = "t3.micro"

  associate_public_ip_address = true

  key_name               = "tech515-carla-aws"
  vpc_security_group_ids = [aws_security_group.target_node_app_sg.id]

  tags = {
    Name = "tech515-carla-new-node-app"
  }
}
