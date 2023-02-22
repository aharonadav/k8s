- npm install WEBSITE_TITLE='Blue Parrot'     WEBSITE_IMAGE='parrot-1.jpg'     WEBSITE_VERSION=1.0.0     node .

- docker build --build-arg TITLE='Green Parrot'     --build-arg IMAGE='parrot-2.jpg'     --build-arg VERSION='1.1.0'     --tag eks-blue-green:1.1.0 .

- aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 889397717348.dkr.ecr.eu-west-1.amazonaws.com

- docker images | awk '{print $1}' | awk 'NR==2'

- docker tag 6d6a48538193 889397717348.dkr.ecr.eu-west-1.amazonaws.com/ecr-tf:parrot-1

- docker push 889397717348.dkr.ecr.eu-west-1.amazonaws.com/ecr-tf:parrot-1

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install prometheus bitnami/kube-prometheus
helm install grafana bitnami/grafana
echo "$(kubectl get secret grafana-admin --namespace default -o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" | base64 --decode)"

xxbCLDqxa0