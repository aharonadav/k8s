resource "kubernetes_deployment" "App1" {
  metadata {
    name = "nginx-deployment"
    namespace = "app1"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
          service_account_name = "app"
          automount_service_account_token = true
          container {
            name = "nginx"
            image = "nginx:latest"
            port {
              container_port = 80
            }
          }
          init_container {
            name = "aws-cli"
            image = "amazon/aws-cli:latest"
            command = [ "aws","s3","ls" ]
          }
      }
    }
  }
}