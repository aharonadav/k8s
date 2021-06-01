resource "kubernetes_namespace" "app1" {
  metadata {
    name = "app1"
  }
}