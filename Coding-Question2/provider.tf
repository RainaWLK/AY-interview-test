terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.1.0"
    }
  }
  backend "s3" {
    bucket         = "my-terraform-state-bucket" 
    key            = "dev/eks-sample/terraform.tfstate"    
    region         = "ap-northeast-1"                       
    encrypt        = true                             
    dynamodb_table = "terraform-state-locking"
  }
}

# 2. Configure the AWS Provider
provider "aws" {
  region = var.region
  profile = var.env
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "dev"
}