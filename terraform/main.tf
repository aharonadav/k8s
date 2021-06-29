provider "aws" {
  region = var.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "k8s-cluster" {
  source = "./modules/k8s-cluster/"
}