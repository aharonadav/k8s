provider "aws" {
  profile = "default"
  region = "eu-west-1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.0"
    }

    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}
