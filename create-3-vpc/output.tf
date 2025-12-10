output "vpc_id" {
  value = aws_vpc.custom.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "app_public_ip" {
  value = aws_instance.app_instance.public_ip
}

output "app_public_dns" {
  value = aws_instance.app_instance.public_dns
}

output "db_private_ip" {
  value = aws_instance.db_instance.private_ip
}

