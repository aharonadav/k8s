resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  count = length(data.aws_vpcs.eks_vpc.ids)
  vpc_id      = data.aws_vpc.eks_vpc[count.index].id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [data.aws_vpc.eks_vpc[0].cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group" "efs-mount-sg" {
  name        = "efs-mount-sg"
  description = "efs-mount-sg"
  count = length(data.aws_vpcs.eks_vpc.ids)
  vpc_id      = data.aws_vpc.eks_vpc[count.index].id

  ingress {
    description      = "efs-mount-sg"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = [data.aws_vpc.eks_vpc[0].cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "efs-mount-sg"
  }
}