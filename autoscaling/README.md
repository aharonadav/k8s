https://www.kubecost.com/kubernetes-autoscaling/kubernetes-vpa/
---
The three types of Kubernetes autoscalers
There are three types of K8s autoscalers, each serving a different purpose. They are:

Horizontal Pod Autoscaler (HPA): adjusts the number of replicas of an application. HPA scales the number of pods in a replication controller, deployment, replica set, or stateful set based on CPU utilization. HPA can also be configured to make scaling decisions based on custom or external metrics.
Cluster Autoscaler (CA): adjusts the number of nodes in a cluster. The Cluster Autoscaler automatically adds or removes nodes in a cluster when nodes have insufficient resources to run a pod (adds a node) or when a node remains underutilized, and its pods can be assigned to another node (removes a node).
Vertical Pod Autoscaler (VPA): adjusts the resource requests and limits (which we’ll define in this article) of containers in the cluster.

==================
Installation:
# Skip this part if you're downloading the conent directly from Aharon repository
- git clone https://github.com/kubernetes/autoscaler.git
- git checkout bb860357f691313fca499e973a5241747c2e38b2
cd autoscaler/vertical-pod-autoscaler
