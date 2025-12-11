########################################
# 1. Récupérer la hosted zone Route53
########################################

data "aws_route53_zone" "talelkarimchebbi" {
  name         = "talelkarimchebbi.com."
  private_zone = false
}

########################################
# 2. Certificat ACM pour api.talelkarimchebbi.com
########################################

resource "aws_acm_certificate" "api_domain" {
  domain_name       = "api.talelkarimchebbi.com"
  validation_method = "DNS"

  # Important pour éviter les problèmes lors de mises à jour
  lifecycle {
    create_before_destroy = true
  }
}

# Enregistrements DNS pour valider le certificat
resource "aws_route53_record" "api_domain_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api_domain.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.talelkarimchebbi.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.record]
}

# Validation du certificat ACM
resource "aws_acm_certificate_validation" "api_domain" {
  certificate_arn         = aws_acm_certificate.api_domain.arn
  validation_record_fqdns = [for record in aws_route53_record.api_domain_validation : record.fqdn]
}

########################################
# 3. Custom domain API Gateway HTTP
########################################

resource "aws_apigatewayv2_domain_name" "vehicles_api" {
  domain_name = "api.talelkarimchebbi.com"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api_domain.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = local.tags

  depends_on = [
    aws_acm_certificate_validation.api_domain
  ]
}

########################################
# 4. API mapping : domaine -> API + stage dev
########################################

resource "aws_apigatewayv2_api_mapping" "vehicles_api_dev" {
  api_id      = module.api_gw_http_vehicles.api_id
  domain_name = aws_apigatewayv2_domain_name.vehicles_api.domain_name
  stage       = local.env # "dev" dans ton cas
}

########################################
# 5. Record Route53 : api.talelkarimchebbi.com -> API Gateway
########################################

resource "aws_route53_record" "api_domain_alias" {
  zone_id = data.aws_route53_zone.talelkarimchebbi.zone_id
  name    = "api.talelkarimchebbi.com"
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.vehicles_api.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.vehicles_api.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
