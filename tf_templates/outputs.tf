output "instances_private_ip" {
  value = [aws_instance.web_servers.*.private_ip]
}

output "bastion_public_ip" {
  value = aws_instance.bastion_server.public_ip
}

output "path" {
  value = path.module
}
output "ip" {
  value = var.subnet_private_ip_range
}

output "key" {
  value = var.private_key
}
