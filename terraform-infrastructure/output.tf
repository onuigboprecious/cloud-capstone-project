output "public_ip" {
  value = aws_eip.formflow.public_ip
}

output "ssh_command" {
  value = "ssh ${var.admin_username}@${aws_eip.formflow.public_ip}"
}
