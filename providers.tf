terraform {
  required_version = ">=1.2.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.21.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.4.0"
    }
  }
}

provider "aws" {
  region = var.region
}
