# Install EKS cluster
 1. Update variables.tf under main folder
 2. Update variables.tf under modules/vpc folder
 3. Update S3 bucket for tfstate
 4. Run the commnd "aws eks --region region update-kubeconfig --name cluster_name"

# Install AWS ALB Ingress
# Install aws-load-balancer-ingress controller
https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html

  helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=aharon-eks-IGwhFvOs \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  -n kube-system

# Expose exist service
https://www.eksworkshop.com/beginner/130_exposing-service/exposing/
kubectl -n prometheus patch svc prometheus-server -p '{"spec": {"type": "NodePort"}}'
kubectl -n prometheus patch svc grafana -p '{"spec": {"type": "LoadBalancer"}}'


# Prometheus & Grafana
## Prometheus
kubectl create namespace monitor

helm install prometheus prometheus-community/prometheus     --namespace monitor     --set alertmanager.persistentVolume.storageClass="gp2"     --set server.persistentVolume.storageClass="gp2"

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
https://www.eksworkshop.com/intermediate/240_monitoring/deploy-grafana/

helm install grafana grafana/grafana \
    --namespace monitor \
    --set persistence.storageClassName="gp2" \
    --set persistence.enabled=true \
    --set adminPassword='EKS!sAWSome' \
    --values grafana.yaml \
    --set service.type=LoadBalancer

  export ELB=$(kubectl get svc -n monitor grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "http://$ELB"

kubectl get secret --namespace monitor grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
