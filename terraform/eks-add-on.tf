resource "aws_eks_addon" "kube_proxy" {
  cluster_name      =  aws_eks_cluster.this.name
  addon_name        = "kube-proxy"
  addon_version     = "v1.25.6-eksbuild.1"
  resolve_conflicts = "OVERWRITE"  
  tags = merge(
    var.tags,
    {
      "eks_addon" = "kube-proxy"
    }
  )
}

resource "aws_eks_addon" "core_dns" {
  cluster_name      = aws_eks_cluster.this.name
  addon_name        = "coredns"
  addon_version     = "v1.9.3-eksbuild.2"
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name      = aws_eks_cluster.this.name
  addon_name        = "vpc-cni"
  addon_version     = "v1.12.5-eksbuild.1"
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name      = aws_eks_cluster.this.name
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = "v1.16.0-eksbuild.1"
  resolve_conflicts = "OVERWRITE"
  depends_on = [
    aws_eks_node_group.this
  ]
}