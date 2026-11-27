output "instance_ids" {
  description = "Map of short key => instance ID"
  value       = { for key, inst in aws_instance.this : key => inst.id }
}

output "private_ips" {
  description = "Map of short key => private IP"
  value       = { for key, inst in aws_instance.this : key => inst.private_ip }
}
