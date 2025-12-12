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


output "frontend_bucket_name" {
  description = "Bucket S3 pour le frontend."
  value       = module.frontend_website.bucket_name
}

output "frontend_website_endpoint" {
  description = "Endpoint HTTP du site statique S3."
  value       = module.frontend_website.website_endpoint
}


output "app_cloudfront_domain" {
  description = "Domain CloudFront (technique)."
  value       = aws_cloudfront_distribution.app_frontend.domain_name
}

output "app_frontend_url" {
  description = "URL finale de l'app frontend."
  value       = "https://app.talelkarimchebbi.com"
}