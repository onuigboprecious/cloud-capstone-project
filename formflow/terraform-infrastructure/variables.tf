variable "location" {
  type    = string
  default = "eastus2"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to your SSH public key, e.g. ~/.ssh/id_ed25519.pub"
}

variable "admin_source_ip" {
  type        = string
  description = "Source IP/CIDR allowed to SSH. Set to '*' to allow GitHub Actions runners, or your IP in CIDR form (e.g. 1.2.3.4/32)"
  default     = "*"
}
