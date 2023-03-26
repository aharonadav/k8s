### Updating an Amazon EKS cluster Kubernetes version

- To update the cluster, Amazon EKS requires up to five available IP addresses from the subnets that you specified when you created your cluster. 

 - To update the Kubernetes version for your cluster
Compare the Kubernetes version of your cluster control plane to the Kubernetes version of your nodes.

Get the Kubernetes version of your cluster control plane.



# Output:
Client Version: v1.24.8
Kustomize Version: v4.5.4
Server Version: v1.24.8-eks-ffeb93d

Get the Kubernetes version of your nodes. This command returns all self-managed and managed Amazon EC2 and Fargate nodes. Each Fargate pod is listed as its own node.


kubectl get nodes
# Output
NAME                                       STATUS   ROLES    AGE     VERSION
ip-10-0-2-10.eu-west-1.compute.internal    Ready    <none>   6h29m   v1.24.10-eks-48e63af
ip-10-0-3-170.eu-west-1.compute.internal   Ready    <none>   6h29m   v1.24.10-eks-48e63af
ip-10-0-3-35.eu-west-1.compute.internal    Ready    <none>   6h29m   v1.24.10-eks-48e63af

# Important #
Before updating your control plane to a new Kubernetes version, make sure that the Kubernetes minor version of both the managed nodes and Fargate nodes in your cluster are the same as your control plane's version. For example, if your control plane is running version 1.24 and one of your nodes is running version 1.23, then you must update your nodes to version 1.24 before updating your control plane to 1.25. 

By default, the pod security policy admission controller is enabled on Amazon EKS clusters. Before updating your cluster, ensure that the proper pod security policies are in place. This is to avoid potential security issues. You can check for the default policy with the kubectl get psp eks.privileged command.


kubectl get psp eks.privileged

# Output
Warning: policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
NAME             PRIV   CAPS   SELINUX    RUNASUSER   FSGROUP    SUPGROUP   READONLYROOTFS   VOLUMES
eks.privileged   true   *      RunAsAny   RunAsAny    RunAsAny   RunAsAny   false            *

If you deployed the Kubernetes Cluster Autoscaler to your cluster before updating the cluster, update the Cluster Autoscaler to the latest version that matches the Kubernetes major and minor version that you updated to.

Open the Cluster Autoscaler releases page in a web browser and find the latest Cluster Autoscaler version that matches your cluster's Kubernetes major and minor version. For example, if your cluster's Kubernetes version is 1.25 find the latest Cluster Autoscaler release that begins with 1.25. Record the semantic version number (1.25.n, for example) for that release to use in the next step.

Set the Cluster Autoscaler image tag to the version that you recorded in the previous step with the following command. If necessary, replace 1.25.n with your own value.


kubectl -n kube-system set image deployment.apps/cluster-autoscaler cluster-autoscaler=registry.k8s.io/autoscaling/cluster-autoscaler:v1.25.n

kubectl version --short --client

## Upgrade kubectl (Optional)
# Before you begin
You must use a kubectl version that is within one minor version difference of your cluster. For example, a v1.26 client can communicate with v1.25, v1.26, and v1.27 control planes. Using the latest compatible version of kubectl helps avoid unforeseen issues.


1. Download the latest release:

1.25
* MAC 
  - Apple Silicon: curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"
  - Intel:    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"

* Linux: curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.25.6/2023-01-30/bin/linux/amd64/kubectl

* Windows: curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.25.6/2023-01-30/bin/windows/amd64/kubectl.exe

2. Validate the binary (optional)

  - curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl.sha256"

  - echo "$(cat kubectl.sha256)  kubectl" | shasum -a 256 --check
If valid, the output is:

kubectl: OK


3. chmod +x ./kubectl

4. Move the kubectl binary to a file location on your system PATH.
  - sudo mv ./kubectl /usr/local/bin/kubectl
  - sudo chown root: /usr/local/bin/kubectl

# Note: Make sure /usr/local/bin is in your PATH environment variable.

5. Test to ensure the version you installed is up-to-date:

kubectl version --client

# Output
kubectl version --client --short
Client Version: v1.26.2
Kustomize Version: v4.5.7