terraform {
  backend "s3" {
    bucket         = "jesquivel-bucket-devsecops"
    region         = "us-east-1"
    key            = "DevSecOps-Tetris-Project/Jenkins-Server-TF/terraform.tfstate"
    use_lockfile   = true
  }
  required_version = ">=1.11.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}