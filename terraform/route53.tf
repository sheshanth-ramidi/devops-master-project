resource "aws_route53_zone" "main" {
  name = "devops-master.com"
 
  tags = {
    Environment = "dev"
    Project     = "devops-master-project"
  }
}
