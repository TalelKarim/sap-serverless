variable "table_name" {
  description = "Nom de la table DynamoDB."
  type        = string
}

variable "billing_mode" {
  description = "Mode de facturation : PAY_PER_REQUEST ou PROVISIONED."
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode doit être PAY_PER_REQUEST ou PROVISIONED."
  }
}

variable "read_capacity" {
  description = "Capacité de lecture (uniquement utilisée si billing_mode = PROVISIONED)."
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Capacité d'écriture (uniquement utilisée si billing_mode = PROVISIONED)."
  type        = number
  default     = 5
}

variable "partition_key_name" {
  description = "Nom de la partition key (hash key)."
  type        = string
  default     = "id"
}

variable "partition_key_type" {
  description = "Type de la partition key : S, N ou B."
  type        = string
  default     = "S"

  validation {
    condition     = contains(["S", "N", "B"], var.partition_key_type)
    error_message = "partition_key_type doit être S, N ou B."
  }
}

variable "sort_key_name" {
  description = "Nom de la sort key (range key), si utilisée."
  type        = string
  default     = null
}

variable "sort_key_type" {
  description = "Type de la sort key : S, N ou B (utilisée seulement si sort_key_name != null)."
  type        = string
  default     = "S"

  validation {
    condition     = contains(["S", "N", "B"], var.sort_key_type)
    error_message = "sort_key_type doit être S, N ou B."
  }
}

variable "table_class" {
  description = "Classe de stockage de la table : STANDARD ou STANDARD_INFREQUENT_ACCESS."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "table_class doit être STANDARD ou STANDARD_INFREQUENT_ACCESS."
  }
}

variable "deletion_protection_enabled" {
  description = "Active la protection contre la suppression de la table."
  type        = bool
  default     = true
}

variable "point_in_time_recovery_enabled" {
  description = "Active le point-in-time recovery (PITR)."
  type        = bool
  default     = true
}

variable "server_side_encryption_enabled" {
  description = "Active le chiffrement au repos avec une clé KMS (gérée par AWS ou custom)."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN de la clé KMS à utiliser pour le chiffrement. Laisser null pour la clé gérée par AWS (alias/aws/dynamodb)."
  type        = string
  default     = null
}

variable "ttl_enabled" {
  description = "Active le TTL sur la table. Si true, ttl_attribute_name doit être renseigné."
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Nom de l'attribut qui contiendra le timestamp d'expiration TTL."
  type        = string
  default     = null
}

variable "stream_enabled" {
  description = "Active les streams DynamoDB."
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Type de données envoyées dans le stream : KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  type        = string
  default     = "NEW_AND_OLD_IMAGES"

  validation {
    condition = contains(
      ["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"],
      var.stream_view_type
    )
    error_message = "stream_view_type doit être KEYS_ONLY, NEW_IMAGE, OLD_IMAGE ou NEW_AND_OLD_IMAGES."
  }
}

variable "tags" {
  description = "Tags à appliquer sur la table."
  type        = map(string)
  default     = {}
}
