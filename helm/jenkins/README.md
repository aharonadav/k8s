# deploy EFS storage driver
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

# get VPC ID
aws eks describe-cluster --name getting-started-eks --query "cluster.resourcesVpcConfig.vpcId" --output text
-results:vpc-011bb222aeb9669c

# Get CIDR range
aws ec2 describe-vpcs --vpc-ids vpc-id --query "Vpcs[].CidrBlock" --output text
-results: 10.0.0.0/16
# security for our instances to access file storage
aws ec2 create-security-group --description efs-test-sg --group-name efs-sg --vpc-id VPC_ID
-results:
{
    "GroupId": "sg-003b71b6709ee888d"
}
aws ec2 authorize-security-group-ingress --group-id sg-xxx  --protocol tcp --port 2049 --cidr VPC_CIDR

# create storage
aws efs create-file-system --creation-token eks-efs
-Result:
{
    "OwnerId": "553686865554",
    "CreationToken": "eks-efs",
    "FileSystemId": "fs-fa1ab3ce",
    "FileSystemArn": "arn:aws:elasticfilesystem:eu-west-1:553686865554:file-system/fs-fa1ab3ce",
    "CreationTime": "2021-06-24T10:00:41+03:00",
    "LifeCycleState": "creating",
    "NumberOfMountTargets": 0,
    "SizeInBytes": {
        "Value": 0,
        "ValueInIA": 0,
        "ValueInStandard": 0
    },
    "PerformanceMode": "generalPurpose",
    "Encrypted": false,
    "ThroughputMode": "bursting",
    "Tags": []
}
:...skipping...
{
    "OwnerId": "553686865554",
    "CreationToken": "eks-efs",
    "FileSystemId": "fs-fa1ab3ce",
    "FileSystemArn": "arn:aws:elasticfilesystem:eu-west-1:553686865554:file-system/fs-fa1ab3ce",
    "CreationTime": "2021-06-24T10:00:41+03:00",
    "LifeCycleState": "creating",
    "NumberOfMountTargets": 0,
    "SizeInBytes": {
        "Value": 0,
        "ValueInIA": 0,
        "ValueInStandard": 0
    },
    "PerformanceMode": "generalPurpose",
    "Encrypted": false,
    "ThroughputMode": "bursting",
    "Tags": []
}

# create mount point 
aws efs create-mount-target --file-system-id FileSystemId --subnet-id SubnetID --security-group GroupID
# X3 (Per private subnet)
Result:
{
    "OwnerId": "553686865554",
    "MountTargetId": "fsmt-1d20f928",
    "FileSystemId": "fs-fa1ab3ce",
    "SubnetId": "subnet-04193b509db81e383",
    "LifeCycleState": "creating",
    "IpAddress": "10.0.3.4",
    "NetworkInterfaceId": "eni-0f0847b95f2e818dc",
    "AvailabilityZoneId": "euw1-az2",
    "AvailabilityZoneName": "eu-west-1c",
    "VpcId": "vpc-011bb222aeb9669c2"
}
# grab our volume handle to update our PV YAML
aws efs describe-file-systems --query "FileSystems[*].FileSystemId" --output text
Result: fs-fa1ab3ce

#Deploy jenkins
- kubectl create ns jenkins
- helm install jenkins jenkins -f jenkins/values.yaml -n jenkins

#Jenkins
- Get password "kubectl -n jenkins exec -it jenkins-b4d464798-4n6b9 cat /var/jenkins_home/secrets/initialAdminPassword"
---> jenkins-b4d464798-4n6b9
bb2e3b84bd4341cfbabc768d0bca1bed

Jenkins deployment version for Jenkins         image: jenkins/jenkins:2.235.1-lts-alpine
