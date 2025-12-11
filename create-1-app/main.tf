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
resource "aws_security_group" "app_sg" {
  name        = var.app_sg_name
  description = var.app_sg_description

  ingress {
    description = var.ssh_port_description
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    # cidr_blocks = [var.ssh_ingress_cidr] # my IP as of 08/12/2025
    cidr_blocks = [local.my_ip_cidr] # Automatically updated IP
  }

  ingress {
    description = var.http_port_description
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = [var.http_ingress_cidr] #check why no []
  }

  ingress {
    description = var.app_port_description
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = var.app_port_ingress_cidrs
  }

  # Allow all outbound traffic
  egress {
    from_port   = var.egress_port
    to_port     = var.egress_port
    protocol    = var.egress_protocol
    cidr_blocks = var.egress_cidrs
  }
}

# Compute
resource "aws_instance" "app_instance" {
  ami                         = var.app_ami_id
  instance_type               = var.vm_instance_type
  associate_public_ip_address = true

  key_name = var.vm_key_name

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # user_data = file("${path.module}/user_data.sh")
  user_data = templatefile("${path.moodule}/app-user-data.tpl", {
    db_private_ip = aws_instance.db_instance.private_ip
  })

  tags = {
    Name = "tech515-carla-tf-app-instance"
  }
}

