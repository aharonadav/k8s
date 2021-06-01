data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

output "endpoint" {
  value = data.aws_eks_cluster.eks_cluster.endpoint
}

# Only available on Kubernetes version 1.13 and 1.14 clusters created or upgraded on or after September 3, 2019.
output "identity-oidc-issuer" {
  value = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}


output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

locals {
  tags = { "Role" = var.role_name }
}

output "Role_Name" {
    value = local.tags
}