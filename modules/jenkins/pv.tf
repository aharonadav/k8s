resource "kubernetes_persistent_volume" "efs-pv" {
  metadata {
    name = "efs-pv"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    volume_mode = "Filesystem"
    access_modes = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name = "efs-sc"
    persistent_volume_source {
        csi {
          driver = "efs.csi.aws.com"
          volume_handle = aws_efs_access_point.ap.id
        }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "efs-claim" {
  metadata {
    name = "efs-claim"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = "efs-sc"
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}