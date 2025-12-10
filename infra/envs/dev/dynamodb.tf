########################
# Locals de l'environnement
########################


########################
# Table DynamoDB : vehicles-dev
########################



#####################################
# Seed de la table vehicles-dev
#####################################

# On définit nos véhicules de test dans un local
locals {
  vehicles_seed = {
    "veh-001" = {
      id    = "veh-001"
      brand = "Tesla"
      model = "Model 3"
      year  = 2024
      color = "black"
    }
    "veh-002" = {
      id    = "veh-002"
      brand = "BMW"
      model = "X1"
      year  = 2021
      color = "white"
    }
    "veh-003" = {
      id    = "veh-003"
      brand = "Audi"
      model = "A3"
      year  = 2022
      color = "blue"
    }
    "veh-004" = {
      id    = "veh-004"
      brand = "Renault"
      model = "Clio"
      year  = 2020
      color = "red"
    }
  }
}

# On crée 1 item DynamoDB par entrée dans local.vehicles_seed
resource "aws_dynamodb_table_item" "seed_vehicles" {
  for_each   = local.vehicles_seed

  table_name = module.vehicles_table.table_name
  hash_key   = "id"  # ta partition key

  # Format attendu = JSON DynamoDB (S pour string, N pour number, etc.)
  item = jsonencode({
    id    = { S = each.value.id }
    brand = { S = each.value.brand }
    model = { S = each.value.model }
    year  = { N = tostring(each.value.year) }
    color = { S = each.value.color }
  })
}



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
