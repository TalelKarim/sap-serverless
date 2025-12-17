terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_region" "current" {}

resource "aws_cognito_user_pool" "this" {
  name = "${var.project}-${var.env}-users"

  # On utilise l'email comme username
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Politique de mot de passe raisonnable
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Email par défaut géré par Cognito
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  tags = merge(var.tags, {
    Project = var.project
    Env     = var.env
  })
}

resource "aws_cognito_user_pool_client" "spa" {
  name         = "${var.project}-${var.env}-spa-client"
  user_pool_id = aws_cognito_user_pool.this.id

  # SPA JS → client public (pas de secret)
  generate_secret = false

  # Flow moderne côté browser
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true

  allowed_oauth_scopes = [
    "openid",
    "email",
    "profile",
  ]

  supported_identity_providers = ["COGNITO"]

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  # Permet password auth et refresh
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = var.domain_prefix
  user_pool_id = aws_cognito_user_pool.this.id
}
