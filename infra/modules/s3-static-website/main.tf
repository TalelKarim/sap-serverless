########################################
# Bucket S3 pour site statique
########################################

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = var.tags
}

# Bloque les ACL legacy, on reste en mode policy only
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Public access block : on autorise le public pour le website hosting
# mais on désactive le block "full" pour pouvoir appliquer une policy
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false  # on autorise une policy publique contrôlée
  restrict_public_buckets = false  # idem
}

########################################
# Static website hosting
########################################

resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

########################################
# Policy publique (GET uniquement)
########################################

data "aws_iam_policy_document" "public_read" {
  statement {
    sid    = "AllowPublicReadForWebsite"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.public_read.json
}
