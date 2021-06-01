output "private_subnets" {
  value = "${module.k8s-cluster.private_subnets}"
}

output "vpc_output" {
    value = "${module.jenkins.eks_vpc}"
}

output "efs_output" {
    value = "${module.jenkins.eks_efs}"
}
