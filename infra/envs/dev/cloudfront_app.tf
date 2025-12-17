
########################################
# CloudFront distribution pour le front
########################################

resource "aws_cloudfront_distribution" "app_frontend" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Frontend app.talelkarimchebbi.com (${local.env})"

  # On sert l'index.html par défaut
  default_root_object = "index.html"

  aliases = [
    "app.talelkarimchebbi.com",
  ]

  # Origin = ton endpoint S3 "static website"
  # module.frontend_website.website_endpoint donne un host du style :
  # talel-frontend-dev.s3-website-eu-west-1.amazonaws.com
  origin {
    domain_name = module.frontend_website.website_endpoint
    origin_id   = "s3-website-frontend-${local.env}"

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  ######################################
  # Comportement par défaut
  ######################################
  default_cache_behavior {
    target_origin_id       = "s3-website-frontend-${local.env}"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]

    cached_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
    ]

    compress = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }

  ######################################
  # SPA friendly : 403/404 -> index.html
  ######################################
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  ######################################
  # Restrictions géographiques (aucune)
  ######################################
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  ######################################
  # Certificat pour HTTPS
  ######################################
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.app_cloudfront.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Pour être sûr que le cert est validé avant la création
  depends_on = [
    aws_acm_certificate_validation.app_cloudfront
  ]

  price_class = "PriceClass_100" # Europe + US (moins cher)

  tags = local.tags
}

