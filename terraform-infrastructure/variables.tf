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
  description = "Name of the existing EC2 key pair"
}

variable "admin_source_ip" {
  type        = string
  description = "Source IP/CIDR allowed to SSH. Use '*' for all or a specific CIDR"
  default     = "*"
}

variable "admin_public_key_path" {
  type        = string
  description = "Path to the SSH public key file for the admin user"
}
