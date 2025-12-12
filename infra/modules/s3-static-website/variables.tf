variable "bucket_name" {
  type        = string
  description = "Nom du bucket S3 pour le site statique. Doit être globalement unique."
}

variable "index_document" {
  type        = string
  description = "Nom du fichier index (document d'accueil)."
  default     = "index.html"
}

variable "error_document" {
  type        = string
  description = "Nom du fichier pour les pages d'erreur."
  default     = "index.html"
}

variable "tags" {
  type        = map(string)
  description = "Tags à appliquer sur les ressources."
  default     = {}
}
