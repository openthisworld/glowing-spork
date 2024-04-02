# Provider Configuration
provider "aws" {
  region = "us-west-2" # Choose your region
}

# Networking
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "default" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.default.id
  route_table_id = aws_route_table.default.id
}

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

  # Define your ingress rules based on your requirements
}

# EC2 Instance
resource "aws_instance" "telegram_bot" {
  ami             = "ami-0c55b159cbfafe1f0" # Update with the latest Amazon Linux 2 AMI in your region
  instance_type   = "t2.micro"
  key_name        = "your-key-pair-name"
  subnet_id       = aws_subnet.default.id
  security_groups = [aws_security_group.telegram_bot.name]

  user_data = <<-EOF
                #!/bin/bash
                git clone <Your-Repository-URL> /home/ec2-user/telegram-bot
                cd /home/ec2-user/telegram-bot
                npm install
                node bot.js > bot_status.txt
              EOF

  tags = {
    Name = "TelegramBotServer"
  }
}

# Outputs
output "ec2_external_ip" {
  value = aws_instance.telegram_bot.public_ip
}

output "bot_status" {
  value = "Check /home/ec2-user/telegram-bot/bot_status.txt for bot status"
}

# Make sure to replace <Your-Repository-URL> with the actual URL of your GitHub repository.
