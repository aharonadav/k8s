resource "kubernetes_service_account" "app1_svc_account" {
  metadata {
    name = "app"
    namespace = "app1"
    annotations = {
      "eks.amazoneks.com/role-arn" = "arn:aws:iam::553686865554:role/App1S3AccessRole"
    }    
  }
}
