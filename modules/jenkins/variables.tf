variable "eks_tag" {
    description = "EKS TAG"
    default = "eks-vpc"
}

variable "region" {
    description = "AWS Region"
    default = "eu-west-1"
}

variable "subnet_id" {
    description = "Node subnet"
    default = "subnet-015ec1868d15c9876"
}