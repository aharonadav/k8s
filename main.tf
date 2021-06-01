terraform {
  backend "s3" {
    bucket = "aharon-terraform"
    key    = "./terrafom.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "k8s-cluster" {
  source = "./modules/k8s-cluster/"
}

module "rbac" {
  source = "./modules/rbac/"
}

module "jenkins" {
  source = "./modules/jenkins/"
}