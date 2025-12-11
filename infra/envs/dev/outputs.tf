output "vehicles_table_name" {
  description = "Nom de la table DynamoDB des véhicules pour cet environnement."
  value       = module.vehicles_table.table_name
}

output "vehicles_table_arn" {
  description = "ARN de la table DynamoDB des véhicules."
  value       = module.vehicles_table.table_arn
}

output "vehicles_api_url" {
  description = "Base URL of the vehicles HTTP API."
  value       = module.api_gw_http_vehicles.api_endpoint
}
