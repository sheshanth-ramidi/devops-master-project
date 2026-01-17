resource "aws_route53_record" "ec2_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "devops.master.com"
  type    = "A"
  ttl     = 300
  records = [aws_instance.devops_ec2.public_ip]
}
