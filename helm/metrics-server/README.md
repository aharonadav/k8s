# Metrics Server
- https://kubernetes-sigs.github.io/metrics-server/


helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/metrics-server --set apiService.create=true