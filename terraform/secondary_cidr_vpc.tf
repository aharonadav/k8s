resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.secondary_cidr_blocks
}

resource "aws_subnet" "secondary_private" {
  count = var.availability_zones_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.secondary_cidr_blocks, var.subnet_cidr_bits, count.index + var.availability_zones_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                           = "${var.project}-private-sg"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
    "kubernetes.io/role/internal-elb"              = 1
  }
}

# Public Subnets
resource "aws_subnet" "secondary_public" {
  count = var.availability_zones_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.secondary_cidr_blocks, var.subnet_cidr_bits, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                           = "${var.project}-public-sg"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
    "kubernetes.io/role/elb"                       = 1
  }

  map_public_ip_on_launch = true
}

resource "aws_eks_node_group" "spots-secondary" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project}-SPOTS-Secondary"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = aws_subnet.secondary_private[*].id

  scaling_config {
    desired_size = 0
    max_size     = 5
    min_size     = 0
  }

  ami_type       = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
  capacity_type  = "SPOT"  # ON_DEMAND, SPOT
  disk_size      = 20
  instance_types = ["t3.medium"]
  
  tags = merge(
    var.tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
}