variable "aws_region" {
  description = "The AWS region to deploy resources in"
  default     = "us-west-2"
}

variable "instance_type" {
  description = "The EC2 instance type"
  default     = "t2.micro"
}

variable "ssh_key_name" {
  description = "The name of the SSH key pair"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key to use for the EC2 instance"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  default     = "10.0.1.0/24"
}

variable "bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
}

variable "bucket_key" {
  description = "The S3 key for the Terraform state file"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
}

variable "repository_url" {
  description = "The URL of the GitHub repository for the bot"
}

variable "bot_main_script" {
  description = "Path to the bot's main script file"
  default     = "bot.js"
}
