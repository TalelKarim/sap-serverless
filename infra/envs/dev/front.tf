########################################
# Site statique frontend (S3 website)
########################################

module "frontend_website" {
  source = "../../modules/s3-static-website"

  # ⚠️ Le nom doit être globalement unique sur S3.
  # Tu peux adapter si nécessaire.
  bucket_name = "talel-frontend-${local.env}"

  index_document = "index.html"
  error_document = "index.html"

  tags = local.tags
}


