terraform {
  cloud {

    organization = "labs_terraform_access"

    workspaces {
      name = "serverless-lab-sap"
    }
  }
}