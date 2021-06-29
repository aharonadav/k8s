resource "kubernetes_namespace" "prometheus" {
  metadata {
    annotations = {
      name = "prometheus"
    }

    labels = {
      mylabel = "prometheus"
    }

    name = "terraform-prometheus"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "14.2.1"

  values = [
    file("modules/monitoring/values.yaml")
  ]

  set {
    name = "namespace"
    value = "prometheus"
  }

  set {
    name  = "cluster.enabled"
    value = "true"
  }

  set {
    name  = "metrics.enabled"
    value = "true"
  }

  set {
    name  = "alertmanager.persistentVolume.storageClass"
    value = "gp2"
  }

  set {
    name  = "server.persistentVolume.storageClass"
    value = "gp2"
  }
  set {
    name  = "service.annotations.prometheus\\.io/port"
    value = "9127"
    type  = "string"
  }
}