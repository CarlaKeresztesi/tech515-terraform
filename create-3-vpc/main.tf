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

# Networking - VPC

resource "aws_vpc" "custom" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "tech515-tf-custom-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom.id

  tags = {
    Name = "tech515-tf-igw"
  }
}

# Public subnet - APP
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.custom.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "tech515-tf-public-subnet"
  }
}

# Private subnet - DB
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.custom.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "tech515-tf-private-subnet"
  }
}

# Public route table + Internet Gateway + association
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.custom.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "tech515-tf-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private route table (no Internet route)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.custom.id

  tags = {
    Name = "tech515-tf-private-rt"
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}


# Networking - Security Groups

# App SG – for app instance in Public subnet
resource "aws_security_group" "app_sg" {
  name        = "tech515-carla-tf-VPC-app-sg"
  description = "Security group for Terraform VPC App instance"
  vpc_id      = aws_vpc.custom.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip_cidr]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tech515-carla-tf-VPC-app-sg"
  }
}


# DB SG - only app SG can hit DB port
resource "aws_security_group" "db_sg" {
  name        = "tech515-carla-tf-VPC-db-sg"
  description = "Security group for database instance"
  vpc_id      = aws_vpc.custom.id

  ingress {
    description = "DB from APP SG only"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tech515-carla-tf-VPC-db-sg"
  }
}

# Compute instances
# APP instance in Public subnet
resource "aws_instance" "app_instance" {
  ami                         = var.app_ami_id
  instance_type               = var.vm_instance_type
  subnet_id = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name = var.vm_key_name

  user_data = file("${path.module}/user_data_app.sh")

  tags = {
    Name = "tech515-carla-tf-VPC-app-instance"
  }
}

# DB instance in Private subnet
resource "aws_instance" "db_instance" {
  ami                         = var.db_ami_id
  instance_type               = var.vm_instance_type
  subnet_id = aws_subnet.private.id
  associate_public_ip_address = false
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  key_name = var.vm_key_name

  tags = {
    Name = "tech515-carla-tf-VPC-db-instance"
  }
}

