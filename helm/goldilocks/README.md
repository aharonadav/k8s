helm install goldilocks --namespace goldilocks --create-namespace --set installVPA=true fairwinds-stable/goldilocks

kubectl label ns default goldilocks.fairwinds.com/enabled=true
kubectl label ns default goldilocks.fairwinds.com/vpa-update-mode="off"

helm repo add cowboysysop https://cowboysysop.github.io/charts/
helm install vpa cowboysysop/vertical-pod-autoscaler