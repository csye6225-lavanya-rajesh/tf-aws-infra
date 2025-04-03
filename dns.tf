data "aws_route53_zone" "selected" {
  name         = var.aws_profile == "dev" ? "dev.${var.domain_name}" : "demo.${var.domain_name}"
  private_zone = false
}

resource "aws_route53_record" "domain" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.aws_profile == "dev" ? "dev.${var.domain_name}" : "demo.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.webapp_alb.dns_name
    zone_id                = aws_lb.webapp_alb.zone_id
    evaluate_target_health = true
  }
}
