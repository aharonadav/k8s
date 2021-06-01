https://aws.amazon.com/blogs/storage/deploying-jenkins-on-amazon-eks-with-amazon-efs/
#
helm install jenkins stable/jenkins --set rbac.create=true,master.servicePort=80,master.serviceType=LoadBalancer,persistence.existingClaim=efs-claim
#
printf $(kubectl get service jenkins -o jsonpath="{.status.loadBalancer.ingress[].hostname}");echo
#
printf $(kubectl get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo
