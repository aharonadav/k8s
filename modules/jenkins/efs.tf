resource "aws_efs_file_system" "eks_efs" {
    creation_token = "${var.eks_tag}-token"
    performance_mode = "generalPurpose"
    throughput_mode = "bursting"
    encrypted = true
    tags = {
        Name = "${var.eks_tag}"
    }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  file_system_id = aws_efs_file_system.eks_efs.id
  subnet_id      = var.subnet_id
}

resource "aws_efs_access_point" "ap" {
  file_system_id = aws_efs_file_system.eks_efs.id
  posix_user {
    uid=1000
    gid=1000
  }
  root_directory {
      path = "/jenkins"
  }
}

resource "null_resource" "kubectl" {
  provisioner "local-exec" {
    command = "kubectl apply -k github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
    interpreter = ["/bin/bash", "-c"]
  }
}

output "eks_efs" {
  value = aws_efs_file_system.eks_efs.id
}