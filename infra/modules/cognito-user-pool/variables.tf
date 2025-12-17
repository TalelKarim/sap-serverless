variable "project" {
  type        = string
  description = "Nom du projet (prefix pour ressources/tags)."
}

variable "env" {
  type        = string
  description = "Environnement (dev, prod, ...)."
}

variable "domain_prefix" {
  type        = string
  description = "Préfixe du domaine Cognito Hosted UI (doit être unique dans la région)."
}

variable "callback_urls" {
  type        = list(string)
  description = "URLs de redirection après login (OAuth2)."
}

variable "logout_urls" {
  type        = list(string)
  description = "URLs de redirection après logout."
}

variable "tags" {
  type        = map(string)
  description = "Tags additionnels à appliquer sur les ressources Cognito."
  default     = {}
}
