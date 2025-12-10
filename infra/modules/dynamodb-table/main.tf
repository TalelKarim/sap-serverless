locals {
  # On gère proprement la liste des attributs de clé (PK + éventuelle SK)
  key_attributes = concat(
    [
      {
        name = var.partition_key_name
        type = var.partition_key_type
      }
    ],
    var.sort_key_name != null ? [
      {
        name = var.sort_key_name
        type = var.sort_key_type
      }
    ] : []
  )
}

resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = var.billing_mode

  # Clé primaire
  hash_key  = var.partition_key_name
  range_key = var.sort_key_name

  table_class                 = var.table_class
  deletion_protection_enabled = var.deletion_protection_enabled

  # Déclaration des attributs de clé (PK + éventuelle SK)
  dynamic "attribute" {
    for_each = {
      for attr in local.key_attributes : attr.name => attr
    }
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }


  # Sauvegarde point-in-time (PITR)
  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  # Chiffrement au repos (SSE)
  server_side_encryption {
    enabled     = var.server_side_encryption_enabled
    kms_key_arn = var.kms_key_arn
  }

  # TTL optionnel
  # ⚠️ Si tu mets ttl_enabled = true, n'oublie pas de définir ttl_attribute_name
  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []
    content {
      enabled        = true
      attribute_name = var.ttl_attribute_name
    }
  }

  # Streams optionnels (pour Lambda, etc.)
  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  tags = var.tags
}
