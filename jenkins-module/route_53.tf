resource "aws_route53_zone" "main" {
  count = var.enable ? 1 : 0
  name  = var.aws_route53_zone_name
}
