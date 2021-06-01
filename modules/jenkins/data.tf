data "aws_vpcs" "eks_vpc" {
  tags = {
    Name = var.eks_tag
  }
}

data "aws_vpc" "eks_vpc" {
  count = length(data.aws_vpcs.eks_vpc.ids)
  id    = tolist(data.aws_vpcs.eks_vpc.ids)[count.index]
}

output "eks_vpc" {
  value = data.aws_vpcs.eks_vpc.ids
}