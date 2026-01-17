output "web_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.devops_ec2.public_ip
}

output "ecr_repository_url" {
  value = aws_ecr_repository.devops_master_app.repository_url
}
