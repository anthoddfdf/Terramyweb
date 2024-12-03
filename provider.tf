terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.6"
    }
  }
}
terraform {
  backend "remote" {
    organization = "Test-cloudpro"

    workspaces {
      name = "myapp"
    }
  }
}





