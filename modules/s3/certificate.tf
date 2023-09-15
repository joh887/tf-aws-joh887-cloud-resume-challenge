resource "aws_acm_certificate" "m" {
    provider = aws.virginia

    domain_name = var.R53DomainName

    validation_method = "DNS"

    subject_alternative_names = ["*.${var.R53DomainName}"]

    key_algorithm = "RSA_2048"

    lifecycle {
        create_before_destroy = true
    }

    tags = {
        Name = "Certificate for ${var.R53DomainName}.",
        Misc = "Made with Terraform."
    }
}

resource "aws_route53_record" "m" {
  for_each = {
    for dvo in aws_acm_certificate.m.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.m.zone_id
}