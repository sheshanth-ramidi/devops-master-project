output "web_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.devops_ec2.public_ip
}
<<<<<<< HEAD
=======

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}
 
output "ecr_repository_name" {
  value = aws_ecr_repository.app.name
}
>>>>>>> d0dfe5b (Update with phase 6)
