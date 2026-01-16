resource "aws_ecr_repository" "app" {
  name                 = var.ecr_repository_name
  image_tag_mutability = var.ecr_image_mutability
 
  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }
 
  encryption_configuration {
    encryption_type = "AES256"
  }
 
  tags = {
    Name        = var.ecr_repository_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
 
resource "aws_ecr_lifecycle_policy" "cleanup" {
  repository = aws_ecr_repository.app.name
 
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
