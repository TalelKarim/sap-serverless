########################
# Locals de l'environnement
########################


########################
# Table DynamoDB : vehicles-dev
########################

module "vehicles_table" {
  source = "../../modules/dynamodb-table"

  # Nom logique de la table pour cet environnement
  table_name = "vehicles-${local.env}"

  # Mode de facturation : on-demand (PAY_PER_REQUEST) pour éviter de gérer RCU/WCU
  billing_mode = "PAY_PER_REQUEST"

  # Clé primaire simple : id (String)
  partition_key_name = "id"
  partition_key_type = "S"

  # Pas de sort key pour ce use case
  # sort_key_name = null (valeur par défaut dans le module)

  # Classe de table STANDARD (par défaut)
  # table_class = "STANDARD"

  # Sécurité & résilience (par défaut dans le module mais je les redonne pour que ce soit explicite)
  deletion_protection_enabled     = true
  point_in_time_recovery_enabled  = true      # PITR activé : rollback possible jusqu’à 35 jours
  server_side_encryption_enabled  = true      # chiffrement au repos
  # kms_key_arn                   = null      # clé KMS gérée par AWS (alias/aws/dynamodb)

  # TTL désactivé pour l’instant
  ttl_enabled         = false
  ttl_attribute_name  = null

  # Streams désactivés pour l’instant (on les activera si on branche des Lambdas dessus)
  stream_enabled   = false
  # stream_view_type = "NEW_AND_OLD_IMAGES"   # utile seulement si stream_enabled = true

  # Tags propagés depuis les locals
  tags = local.tags
}
