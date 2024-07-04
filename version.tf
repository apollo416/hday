terraform {
  required_version = "1.9.1"

  cloud {
    organization = "apollo416"
    workspaces {
      project = "hday"
      tags    = ["hday"]
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}