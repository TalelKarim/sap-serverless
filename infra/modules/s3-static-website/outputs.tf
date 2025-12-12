output "bucket_name" {
  description = "Nom du bucket S3 du site statique."
  value       = aws_s3_bucket.this.bucket
}

output "website_endpoint" {
  description = "Endpoint HTTP du site statique S3."
  value       = aws_s3_bucket_website_configuration.this.website_endpoint
}
