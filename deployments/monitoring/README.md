# Install aws-load-balancer-ingress controller
https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html

  helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=aharon-eks-IGwhFvOs \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  -n kube-system

# Prometheus & Grafana
## Prometheus
kubectl create namespace prometheus

helm install prometheus prometheus-community/prometheus     --namespace prometheus     --set alertmanager.persistentVolume.storageClass="gp2"     --set server.persistentVolume.storageClass="gp2"

## Grafana
touch grafana.yaml
>>
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server.prometheus.svc.cluster.local
      access: proxy
      isDefault: true
>>
https://www.eksworkshop.com/intermediate/240_prometheusing/deploy-grafana/

helm install grafana grafana/grafana \
    --namespace prometheus \
    --set persistence.storageClassName="gp2" \
    --set persistence.enabled=true \
    --set adminPassword='EKS!sAWSome' \
    --values grafana.yaml \
    --set service.type=LoadBalancer

  export ELB=$(kubectl get svc -n prometheus grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "http://$ELB"

kubectl get secret --namespace prometheus grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo


Grafana monitor import dashboard 3119
