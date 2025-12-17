module "cognito_users" {
  source = "../../modules/cognito-user-pool"

  project       = local.project        # ex: "serverless-lab"
  env           = local.env           # ex: "dev"
  domain_prefix = "talel-dev-auth"    # doit être unique dans eu-west-1

  # IMPORTANT: ces URLs doivent correspondre à ton front
  callback_urls = [
    "https://app.talelkarimchebbi.com/callback",
  ]

  logout_urls = [
    "https://app.talelkarimchebbi.com/",
  ]

  tags = local.tags
}

