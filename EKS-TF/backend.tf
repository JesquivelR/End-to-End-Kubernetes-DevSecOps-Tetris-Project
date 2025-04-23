terraform {
  backend "s3" {
    bucket         = "jesquivel-bucket-devsecops"
    region         = "us-east-1"
    key            = "DevSecOps-Tetris-Project/EKS-TF/terraform.tfstate"
    use_lockfile   = true
  }
  required_version = ">=0.13.0"
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"
    }
  }
}