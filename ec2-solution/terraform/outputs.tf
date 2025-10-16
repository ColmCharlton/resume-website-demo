output "resume_instance_public_ip" {
  value       = var.instance_count == 1 ? aws_instance.webserver[0].public_ip : null
  description = "Public IP of the first webserver instance (for backward compatibility)"
}

output "resume_instance_public_dns" {
  value       = var.instance_count == 1 ? aws_instance.webserver[0].public_dns : null
  description = "Public DNS of the first webserver instance (for backward compatibility)"
}

# New outputs for multiple instances
output "all_webserver_public_ips" {
  value       = aws_instance.webserver[*].public_ip
  description = "List of all webserver public IPs"
}

output "all_webserver_public_dns" {
  value       = aws_instance.webserver[*].public_dns
  description = "List of all webserver public DNS names"
}

output "all_webserver_private_ips" {
  value       = aws_instance.webserver[*].private_ip
  description = "List of all webserver private IPs"
}

output "bastion_instance_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_instance_public_dns" {
  value = aws_instance.bastion.public_dns
}

# output "vpc_id" {
#   value = aws_vpc.main.id  # Commented out: resource not defined
# }

# output "public_subnet_ids" {
#   value = aws_subnet.public[*].id  # Commented out: resource not defined
# }

# output "private_subnet_ids" {
#   value = aws_subnet.private[*].id  # Commented out: resource not defined
# }
