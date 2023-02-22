resource "kubernetes_deployment" "parrot" {
  metadata {
    name      = "parrot-deployment"
    namespace = "default"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "parrot"
      }
    }
    template {
      metadata {
        labels = {
          app = "parrot"
        }
      }
      spec {
        container {
          image = "889397717348.dkr.ecr.eu-west-1.amazonaws.com/ecr-tf:parrot-1"
          name  = "parrot"
          port {
            container_port = 3000 
          }
        }
      }
    }
  }
}
