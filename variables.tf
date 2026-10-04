variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}
variable "environment" {
  description = "Deployment environment"
  type        = string
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "subnet_cidr" {
  description = "CIDR block for the environment subnet"
  type        = string
}
variable "instance_type" {
  description = "EC2 instance type for the environment"
  type        = string
}