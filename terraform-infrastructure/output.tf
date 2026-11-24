output "public_ip" {
  description = "Elastic IP address of the FormFlow instance"
  value       = aws_eip.formflow.public_ip
}

output "ssh_command" {
  description = "Ready‑to‑run SSH command using the admin username"
  value       = "ssh ${var.admin_username}@${aws_eip.formflow.public_ip}"
}
