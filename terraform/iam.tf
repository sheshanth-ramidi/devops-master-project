############################################
# IAM ROLE FOR EC2 (ECR ACCESS)
############################################
 
resource "aws_iam_role" "ec2_role" {
  name = "ec2-devops-role"
 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
 
############################################
# ATTACH ECR READ POLICY TO ROLE
############################################
 
resource "aws_iam_role_policy_attachment" "ec2_ecr_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
 
############################################
# INSTANCE PROFILE FOR EC2
############################################
 
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-devops-profile"
  role = aws_iam_role.ec2_role.name
}
