output "user_pool_id" {
  description = "ID du user pool Cognito."
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_arn" {
  description = "ARN du user pool Cognito."
  value       = aws_cognito_user_pool.this.arn
}

output "user_pool_client_id" {
  description = "Client ID de l'application SPA."
  value       = aws_cognito_user_pool_client.spa.id
}

output "issuer_url" {
  description = "URL de l'issuer (iss) utilisée dans l'authorizer JWT d'API Gateway."
  value       = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.this.id}"
}

output "hosted_ui_base_url" {
  description = "URL de base de la Hosted UI Cognito."
  value       = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.name}.amazoncognito.com"
}
