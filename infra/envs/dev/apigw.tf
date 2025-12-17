########################
# HTTP API - Vehicles backend
########################

module "api_gw_http_vehicles" {
  source = "../../modules/api-gw-http"

  name        = "vehicles-api-${local.env}"
  description = "HTTP API for the serverless vehicles app (${local.env})."
  stage_name  = local.env

  routes = {
    get_all = {
      lambda_arn = module.lambda_find_all_vehicles.function_arn
      route_key  = "GET /vehicles"
    }
    get_one = {
      lambda_arn = module.lambda_find_vehicle.function_arn
      route_key  = "GET /vehicles/{id}"
    }
  }

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.vehicles_jwt.id
  
  tags = local.tags
}



resource "aws_apigatewayv2_authorizer" "vehicles_jwt" {
  api_id          = module.api_gw_http_vehicles.api_id
  name            = "vehicles-jwt-authorizer"
  authorizer_type = "JWT"

  identity_sources = [
    "$request.header.Authorization",
  ]

  jwt_configuration {
    audience = [module.cognito_users.user_pool_client_id]
    issuer   = module.cognito_users.issuer_url
  }
}
