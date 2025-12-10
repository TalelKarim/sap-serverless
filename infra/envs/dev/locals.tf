locals {
  # Nom de projet global (utilisable dans d'autres envs : dev, prod, etc.)
  project = "serverless-lab"

  # Nom de l'environnement courant
  env = "dev"

  # Tags communs à toutes les ressources de cet env
  tags = {
    Project = local.project
    Env     = local.env
  }
}
