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

variable "ECR_name" {
  description = "ECR name"
  type        = string
}

variable "backend_repo_name" {
  description = "Name for the backend ECR repository"
  type        = string
  default     = "devops-master-backend"
}
 
variable "frontend_repo_name" {
  description = "Name for the frontend ECR repository"
  type        = string
  default     = "devops-master-frontend"
}
