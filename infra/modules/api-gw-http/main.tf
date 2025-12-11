################################
# HTTP API
################################

resource "aws_apigatewayv2_api" "this" {
  name          = var.name
  description   = var.description
  protocol_type = "HTTP"

  dynamic "cors_configuration" {
    for_each = var.cors_enabled ? [1] : []
    content {
      allow_origins = var.cors_allow_origins
      allow_methods = var.cors_allow_methods
      allow_headers = ["*"]
    }
  }

  tags = var.tags
}

################################
# Stage
################################

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  auto_deploy = true

  tags = var.tags
}

################################
# Integrations & Routes
################################

resource "aws_apigatewayv2_integration" "this" {
  for_each = var.routes

  api_id = aws_apigatewayv2_api.this.id

  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = each.value.lambda_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "this" {
  for_each = var.routes

  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.this[each.key].id}"
}

################################
# Lambda permissions
################################

resource "aws_lambda_permission" "apigw" {
  for_each = var.routes

  statement_id  = "AllowAPIGatewayInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}
