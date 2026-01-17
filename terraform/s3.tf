resource "aws_s3_bucket" "devops_bucket" {
  bucket = "devops-master-${random_id.bucket_id.hex}"
 
  tags = {
    Name        = "devops-master-bucket"
    Environment = "dev"
  }
}
