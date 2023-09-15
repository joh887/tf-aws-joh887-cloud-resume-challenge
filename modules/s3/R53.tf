data "aws_route53_zone" "m" {
  name = var.R53DomainName
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.m.zone_id
  name = "www.${var.R53DomainName}"

  type = "A"
  
    alias {
    name                   = aws_cloudfront_distribution.cloud_resume_site_bucket.domain_name
    zone_id                = aws_cloudfront_distribution.cloud_resume_site_bucket.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "m-cf" {
  zone_id = data.aws_route53_zone.m.zone_id
  name    = "${var.R53DomainName}"

  type = "A"

  alias {
    name = aws_cloudfront_distribution.cloud_resume_site_bucket.domain_name
    zone_id = aws_cloudfront_distribution.cloud_resume_site_bucket.hosted_zone_id
    evaluate_target_health = false
  }
}