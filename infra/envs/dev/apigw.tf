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

  tags = local.tags
}
