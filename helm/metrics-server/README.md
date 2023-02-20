# Metrics Server
- https://kubernetes-sigs.github.io/metrics-server/


helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/metrics-server --set apiService.create=true


helm install goldilocks --namespace goldilocks --create-namespace --set installVPA=true fairwinds-stable/goldilocks

kubectl label ns default goldilocks.fairwinds.com/enabled=true
kubectl label ns default goldilocks.fairwinds.com/vpa-update-mode="off"

git clone https://github.com/kubernetes/autoscaler.git
git checkout bb860357f691313fca499e973a5241747c2e38b2