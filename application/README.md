# Get Login Password
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 553686865554.dkr.ecr.eu-west-1.amazonaws.com

# Push the Docker Image
docker push 553686865554.dkr.ecr.eu-west-1.amazonaws.com/k8s_demo:1

# Node IAM
Node role policies:
AmazonEC2ContainerRegistryReadOnly
AmazonEC2ContainerRegistryPowerUser

>>>Deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kubeapp-ecr
  labels:
    app: kubeapp-ecr
spec:
  replicas: 2
  selector:
   matchLabels:
      app: kubeapp-ecr
  template:
    metadata:
      labels:
        app: kubeapp-ecr
    spec:
      containers:
      - name: kubeapp-ecr
        image: 553686865554.dkr.ecr.eu-west-1.amazonaws.com/k8s_demo:1
        resources:
          requests:
            memory: "128Mi"
            cpu: "500m"
          limits:
            memory: "256Mi"
            cpu: "1000m"
        ports:
          - containerPort: 80
>>>Service.yml
#02-ECR-Nginx-NodePortService.yml
apiVersion: v1
kind: Service
metadata:
  name: kubeapp-ecr-nodeport-service
  labels:
   app: kubeapp-ecr
  annotations:    
#Important Note:  Need to add health check path annotations in service level if we are planning to use multiple targets in a load balancer    
   alb.ingress.kubernetes.io/healthcheck-path: /index.html    
spec:
  type: LoadBalancer
  selector:
   app: kubeapp-ecr
  ports:
    - port: 80
      targetPort: 80

# CI/CD
1. Update the index.html
2. docker build -t webserver .
3. docker image tag webserver:latest 111111111.dkr.ecr.eu-west-1.amazonaws.com/k8s_demo:3
4. docker push 111111111.dkr.ecr.eu-west-1.amazonaws.com/k8s_demo:2
5. Update deployment.yml with the new version
# > Not must < #
6. kubectl get deployment == ($output)
7. kubectl rollout restart deployment $output