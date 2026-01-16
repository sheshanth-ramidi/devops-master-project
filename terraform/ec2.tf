resource "aws_instance" "devops_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.devops_sg.id]
 
  key_name = var.key_name
  
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
 
   metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name = "devops-server"
  }
}
