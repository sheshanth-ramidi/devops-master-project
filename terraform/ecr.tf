resource "aws_ecr_repository" "devops_master_app" {
  name                 = var.ECR_name
  image_tag_mutability = "MUTABLE"
 
  image_scanning_configuration {
    scan_on_push = true
  }
 
  encryption_configuration {
    encryption_type = "AES256"
  }
 
  tags = {
    Name        = "devops-master-app"
    Environment = "dev"
    Project     = "devops-master-project"
  }
}
 
# Optional but RECOMMENDED (auto cleanup old images)
resource "aws_ecr_lifecycle_policy" "cleanup_policy" {
  repository = aws_ecr_repository.devops_master_app.name
 
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
