# Configure AWS provider
provider "aws" {
  region = var.default_region
}

# Get current IP at plan/apply time - for an Automatically updated IP
data "http" "my_ip" {
  url = "https://api.ipify.org"
}

# Convert it into a /32 CIDR - for an Automatically updated IP
locals {
  my_ip_cidr = "${data.http.my_ip.response_body}/32"
}

# Networking Security Group
resource "aws_security_group" "db_sg" {
  name        = var.db_sg_name
  description = var.db_sg_description

  ingress {
    description = var.db_port_description
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Compute
resource "aws_instance" "db_instance" {
  ami                         = var.db_ami_id
  instance_type               = var.vm_instance_type

  # Define custom network interface to control the network settings of the EC2 instance, 
  #instead of letting AWS choose defaults (like auto-assigning public IPs)
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  associate_public_ip_address = var.just_private_ip

  key_name = var.vm_key_name

  tags = {
    Name = "tech515-carla-tf-db-instance"
  }
}

