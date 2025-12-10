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
   # cidr_blocks = [var.db_ingress_cidr]
    security-groups = [var.app_sg_id]
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
  ami                         = var.db_ami_id
  instance_type               = var.vm_instance_type
  associate_public_ip_address = true

  key_name = var.vm_key_name

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "tech515-carla-tf-app-instance"
  }
}

