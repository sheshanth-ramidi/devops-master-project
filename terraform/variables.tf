variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}
<<<<<<< HEAD
=======

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
}
 
variable "ecr_image_mutability" {
  description = "Image tag mutability"
  type        = string
  default     = "MUTABLE"
}
 
variable "ecr_scan_on_push" {
  description = "Enable image scan on push"
  type        = bool
  default     = true
}
>>>>>>> d0dfe5b (Update with phase 6)
