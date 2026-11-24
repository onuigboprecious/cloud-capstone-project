terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# AWS provider is configured in provider.tf

# Data source for latest Ubuntu Jammy AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_vpc" "formflow" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "vpc-formflow"
  }
}

resource "aws_subnet" "formflow" {
  vpc_id                  = aws_vpc.formflow.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet-formflow"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.formflow.id
  tags = {
    Name = "igw-formflow"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.formflow.id
  tags = {
    Name = "rt-formflow"
  }
}

resource "aws_route" "default" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.formflow.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "formflow" {
  name        = "sg-formflow"
  description = "Allow SSH, HTTP, HTTPS"
  vpc_id      = aws_vpc.formflow.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_source_ip]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["*"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["*"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["*"]
  }

  tags = {
    Name = "sg-formflow"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.ssh_key_name
  public_key = file(var.admin_public_key_path)
}

resource "aws_instance" "formflow" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.formflow.id
  vpc_security_group_ids      = [aws_security_group.formflow.id]
  key_name                    = var.ssh_key_name
  associate_public_ip_address = true
  tags = {
    Name = "formflow-${var.environment}"
  }

  # Cloud‑init to install Docker and Docker Compose
  user_data = <<-EOF
    #cloud-config
    package_update: true
    packages:
      - docker.io
      - docker-compose-v2
    runcmd:
      - systemctl enable --now docker
      - usermod -aG docker ${var.admin_username}
  EOF
}

# Elastic IP attached to the instance
resource "aws_eip" "formflow" {
  instance = aws_instance.formflow.id
  tags = {
    Name = "eip-formflow"
  }
}
