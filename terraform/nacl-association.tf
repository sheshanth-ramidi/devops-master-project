resource "aws_network_acl_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  network_acl_id = aws_network_acl.public_nacl.id
}

