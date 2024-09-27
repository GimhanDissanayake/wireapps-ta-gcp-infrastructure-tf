terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "wireapps-ta"

    workspaces {
      prefix = "wireapps-ta-gcp-infrastructure-"
    }
  }

  required_providers {

    google = {
      source = "hashicorp/google"
    }
  }

  required_version = ">= 1.7"
}