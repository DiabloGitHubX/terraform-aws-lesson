terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "open-horizons"
}
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = "terraform-${var.environment}-vpc"
    Environment = var.environment
    Project     = "terraform-aws-lesson"
  }
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name        = "terraform-${var.environment}-public-subnet"
    Environment = var.environment
    Project     = "terraform-aws-lesson"
  }
}
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "terraform-${var.environment}-igw"
    Environment = var.environment
    Project     = "terraform-aws-lesson"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "terraform-${var.environment}-public-rt"
    Environment = var.environment
    Project     = "terraform-aws-lesson"
  }
}
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_security_group" "ssh" {
  name        = "terraform-${var.environment}-ssh"
  description = "Allow SSH access from my IP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["87.68.237.44/32"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "terraform-${var.environment}-ssh"
    Environment = var.environment
    Project     = "terraform-aws-lesson"
  }
}
resource "aws_key_pair" "terraform_lesson" {
  key_name   = "terraform-${var.environment}-key"
  public_key = file("~/.ssh/terraform-lesson.pub")

  tags = {
    Name        = "terraform-${var.environment}-key"
    Environment = var.environment
    Project     = "terraform-aws-lesson"
  }
}
resource "aws_instance" "web" {
  ami                         = "ami-04478a3e21a0d79a7"
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.terraform_lesson.key_name

  tags = {
    Name        = "terraform-${var.environment}-web"
    Environment = var.environment
    Project     = "terraform-aws-lesson"
  }
}