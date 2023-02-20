helm install goldilocks --namespace goldilocks --create-namespace --set installVPA=true fairwinds-stable/goldilocks

helm repo add cowboysysop https://cowboysysop.github.io/charts/
helm install vpa cowboysysop/vertical-pod-autoscaler

kubectl label ns <NAMESPACE> goldilocks.fairwinds.com/enabled=true
kubectl label ns <NAMESPACE> goldilocks.fairwinds.com/vpa-update-mode="off"

For example:
kubectl label ns default goldilocks.fairwinds.com/enabled=true
kubectl label ns default goldilocks.fairwinds.com/vpa-update-mode="off"

You can create your next namespaces following the example:

namespace.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: ait
  labels:
    name: ait
    goldilocks.fairwinds.com/enabled: "true"
    goldilocks.fairwinds.com/vpa-update-mode: "off"

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress
  namespace: kubecost
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: "kubecost"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: kubecost-cost-analyzer
            port:
              number: 9090
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress
  namespace: goldilocks
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: "goldilocks"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: goldilocks-dashboard
            port:
              number: 80