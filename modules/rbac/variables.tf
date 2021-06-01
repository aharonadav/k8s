variable "eks_cluster_name" {
    type = string
    description = "AWS EKS Cluster name"
    default = "aharon-eks-IGwhFvOs"
}

variable "eks_cluster_role_arn" {
    type = string
    description = "AWS EKS Cluster role arn"
    default = "arn:aws:iam::553686865554:role/aharon-eks-IGwhFvOs20210518210010449300000002"
}

variable "bucket_name" {
    type = string
    description = "AWS S3 bucket name"
    default = "aharon-app1"
}

variable "oidc_url" {
    type = string
    description = "EKS OIDC URL"
    default = "https://oidc.eks.eu-west-1.amazonaws.com/id/DD149895E0A9089BE4988890BA7D9815"
}

variable "oidc_arn" {
    type = string
    description = "EKS OIDC ARN"
    default = "arn:aws:iam::553686865554:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/DD149895E0A9089BE4988890BA7D9815"
}

variable "oidc_condition" {
    type = string
    default = "oidc.eks.eu-west-1.amazonaws.com/id/DD149895E0A9089BE4988890BA7D9815"
  
}
variable "role_name" {
    type = string
    description = "IAM Role name"
    default = "App1S3AccessRole"
}
