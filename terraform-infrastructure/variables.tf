variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "admin_username" {
  type    = string
  default = "ubuntu"
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the EC2 key pair to create"
  default     = "formflow-key"
}

variable "admin_source_ip" {
  type        = string
  description = "Source IP/CIDR allowed to SSH. Use '*' for all or a specific CIDR"
  default     = "0.0.0.0/0"
}

variable "admin_public_key_path" {
  type        = string
  description = "Path to the SSH public key file for the admin user"
}

