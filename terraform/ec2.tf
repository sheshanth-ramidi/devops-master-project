resource "aws_instance" "devops_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.devops_sg.id]
 
  key_name = var.key_name
 
  tags = {
    Name = "devops-server"
  }
}
