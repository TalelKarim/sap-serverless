output "table_name" {
  description = "Nom de la table DynamoDB."
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "ARN de la table DynamoDB."
  value       = aws_dynamodb_table.this.arn
}

output "table_id" {
  description = "ID de la table (souvent identique au nom)."
  value       = aws_dynamodb_table.this.id
}

output "stream_arn" {
  description = "ARN du stream DynamoDB (null si stream désactivé)."
  value       = aws_dynamodb_table.this.stream_arn
}
