variable "name" {
  type        = string
  description = "Name of the HTTP API."
}

variable "description" {
  type        = string
  description = "Description of the HTTP API."
  default     = ""
}

variable "stage_name" {
  type        = string
  description = "Stage name (e.g. dev, prod)."
  default     = "dev"
}

variable "routes" {
  description = "Map of routes with their Lambda integrations."
  type = map(object({
    lambda_arn = string
    route_key  = string # e.g. \"GET /vehicles\"
  }))
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default     = {}
}

variable "cors_enabled" {
  type        = bool
  description = "Enable CORS configuration."
  default     = true
}

variable "cors_allow_origins" {
  type        = list(string)
  description = "CORS allowed origins."
  default     = ["*"]
}

variable "cors_allow_methods" {
  type        = list(string)
  description = "CORS allowed methods."
  default     = ["GET", "OPTIONS"]
}



variable "authorization_type" {
  default = null
}

variable "authorizer_id" {
  default = null
}