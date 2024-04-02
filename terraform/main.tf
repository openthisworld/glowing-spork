provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
}

# Subnet
resource "aws_subnet" "default" {
  vpc_id     = aws_vpc.default.id
  cidr_block = var.subnet_cidr
  map_public_ip_on_launch = true
}

# Internet Gateway
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

# Route Table
resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

# Associate Route Table
resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.default.id
  route_table_id = aws_route_table.default.id
}

# Security Group
resource "aws_security_group" "telegram_bot" {
  name        = "telegram_bot_sg"
  description = "Security group for Telegram bot"
  vpc_id      = aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Add ingress rules as needed
}

# Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = var.ssh_key_name
  public_key = file(var.ssh_public_key_path)
}

# EC2 Instance
resource "aws_instance" "telegram_bot" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.deployer.key_name
  subnet_id       = aws_subnet.default.id
  security_groups = [aws_security_group.telegram_bot.name]

  user_data = <<-EOF
                #!/bin/bash
                git clone ${var.repository_url} /home/ec2-user/telegram-bot
                cd /home/ec2-user/telegram-bot/src
                npm install
                node ${var.bot_main_script} > /home/ec2-user/telegram-bot-status.txt
              EOF

  tags = {
    Name = "TelegramBotServer"
  }
}

# Outputs
output "ec2_ip" {
  value = aws_instance.telegram_bot.public_ip
}
