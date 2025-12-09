
provider "aws" {
  # use Ireland region
  region = "eu-west-1"
}

# Networking Security Group
resource "aws_security_group" "app_sg" {
  name        = "tech515-carla-tf-allow-port-22-3000-80"
  description = "Allow SSH from my IP, ports 3000 and 80 from Anywhere"

  # Allow SSH (22) from 81.132.59.177 
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["81.132.59.177/32"] # my IP as of 08/12/2025
  }

  # Allow HTTP (80) from Anywhere
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow app port 3000 from Anywhere
  ingress {
    description = "Port 3000 from anywhere"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Compute
resource "aws_instance" "app_instance" {
  ami                         = "ami-0c1c30571d2dae5c9"
  instance_type               = "t3.micro"
  associate_public_ip_address = true

  key_name = "tech515-carla-aws"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "tech515-carla-tf-first-instance"
  }
}

