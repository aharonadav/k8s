Exam:
Certified Kubernetes Administrator: https://www.cncf.io/certification/cka/

Exam Curriculum (Topics): https://github.com/cncf/curriculum

Candidate Handbook: https://www.cncf.io/certification/candidate-handbook

Exam Tips: http://training.linuxfoundation.org/go//Important-Tips-CKA-CKAD

Use the code – DEVOPS15 – while registering for the CKA or CKAD exams at Linux Foundation to get a 15% discount.

----------------
Lean GitHub documents:https://github.com/kodekloudhub/certified-kubernetes-administrator-course

ETCD - Is a database of key/value.
       Identifies if the node is able to get more containers. Knows the number of containers on the nodes.

Scheduler - Is a pod that run on kube-sytem and knows the right node to place the         pod on it. By knowing the capacity on the, etc.

NodeController - Managing the replicas and including the node controller
                 Handeling situations when node became unavailable

kube-apiserver - Responsible on the orchestrator the mangae the applications.
           Expose the k8s api's that used for human actions to manage the cluster.
           FOR Example - run "kubectl get nodes" going through the kube-apiserver and it retrieves the data from the ETCD back to the user.
           ANOTHER EXAMPLE: kubectl create pods make the kube-apiserver to sends a command to the kubelet on the node

kubelet - Is an agent that runs on each node in the cluster.
          Creating and destroying containers by getting commands from the kube-apiserver.

kube-proxy - Run on the worker node and responsible on the communication between the node.        For example, one container on one node need to communicate with another container on a different node (nginx and sql)

Commands - Shortcats:
Create an NGINX Pod

kubectl run nginx --image=nginx

Generate POD Manifest YAML file (-o yaml). Don’t create it(–dry-run)

kubectl run nginx --image=nginx --dry-run=client -o yaml

Create a deployment

kubectl create deployment --image=nginx nginx

Generate Deployment YAML file (-o yaml). Don’t create it(–dry-run)

kubectl create deployment --image=nginx nginx --dry-run=client -o yaml

Generate Deployment YAML file (-o yaml). Don’t create it(–dry-run) with 4 Replicas (–replicas=4)

kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > nginx-deployment.yaml

Save it to a file, make necessary changes to the file (for example, adding more replicas) and then create the deployment.

kubectl create -f nginx-deployment.yaml

OR

In k8s version 1.19+, we can specify the –replicas option to create a deployment with 4 replicas.

kubectl create deployment --image=nginx nginx --replicas=4 --dry-run=client -o yaml > nginx-deployment.yaml

kubectl expose pod redis --port 6379 --name redis-service
#Create a pod+service and expose
kubectl run httpd --image=httpd:alpine --port=80 --expose

kubectl run --image=redis:alpine redis --labels="tier=db"
kubectl create deployment webapp --image=kodekloud/webapp-color --replicas=3

kubectl get pods --selector="env=dev,type=frontend"
#Taint configured on a node to allow only specific pods to be on it.
kubectl taint nodes node-name key=value:taint-effect
* The taint-effect decides what will happen to the node:
 - NoSchedule: Pod will not be scheduled on the node
 - PreferNoSchedule: The system will try not to add it to this node(Not gurenteed)
 - NoExecute: New pods will not be scheduled on this node and exists pods will be victemed and need to be tolerance accordingly

kubectl taint nodes node1 app=blue:NoSchedule 
apiVersion: v1
kind: Pod
metadata:
  name: bee
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  tolerations:
  - key: "spray"
    operator: "Equal"
    value: "mortein"
    effect: "NoSchedule"
    ---------------

Node Selector:
You can add to the node a label of "Large":
kubectl lable node node01 size-Large
AND the pod will have under spec:
nodeSelector:
  size: Large

Node Affinity:
- Verify pod to relevant Node
Under spec:
* DuringScheduling: during the pod creation.

Example: (The node will have lable "color:blue")
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: blue
  name: blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: blue
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: blue
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: color
                operator: In
                values:
                - blue
      containers:
      - image: nginx
        name: nginx
        resources: {}
status: {}

* NodeSelector
apiVersion: v1
kind: Pod
metadata:
  name: cuda-test
spec:
  containers:
    - name: cuda-test
      image: "registry.k8s.io/cuda-vector-add:v0.1"
      resources:
        limits:
          nvidia.com/gpu: 1
  nodeSelector:
    accelerator: nvidia-tesla-p100

--------------
Resource Limits:
POD
  spec:
    containers:
    - name: nginx
      image: nginx
      imagePullPolicy: IfNotPresent
      
      resources:
        requests:
          memory: "1Gi"
          cpu: 1
        limits:
          memory: "2Gi"
          cpu: 2
------------------
DaemonSet:
DaemonSets ensure that one pod will be present on each node of the cluster.
Used for Monitoring and logs, as we will need to get the status of each node.
Another example is kube-proxy

apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: kube-system
  labels:
    k8s-app: fluentd
spec:
  selector:
    matchLabels:
      name: fluentd
  template:
    metadata:
      labels:
        name: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluentd:latest
--------------------
Static PODS
There are pods on the node that provisioned by the KUBELET on the node.
In order to create the pods, the YAML file should be located on the path /etc/kubernetes/manifest and it will automatically build the pod.
Another way to set the path, is by kubeconfig.yaml:
staticPodPath: /etc/kubernetes/manifest

This set by the file: kubelet.service using --config=kubeconfig.yaml

docker ps to get the running pods as the master is disconnected.
The kubelet first priority is the master and the second is the file.

    command: ["/bin/sh", "-c"]
    args:
      - echo starting;
        ls -la /backups;
        mysqldump --host=... -r /backups/file.sql db_name;
        ls -la /backups;
        echo done;
    env:
      - name: APP_COLOR
        value: pink
--------------------
spec:
  containers:
  schedulerName: *****

kubectl get events
kubectl logs my-customer-scheduler -n=kube-system
---------------------
Rolling updates and RollBack

kubectl create deployment
kubectl get deployments
kubectl set image deployment/<deploymentName> applicationName=nginx:1.9.1
kubectl rollout status deployment/<deploymentName>
kubectl rollout history deployment/<deploymentName>
kubectl rollout undo deployment/<deploymentname>
---------------------------------------------------------------
ConfigMap
* Option1:
kubectl create configmap \
    app-config --from-literal=APP_COLOR=blue \
               --from-literal=APP_COLOR=green
* Option2:
kubectl create configmap app-config --from-file=app_config.properties

* Option3:
config-map.yaml:
apiVersion: v1
kind: ConfigMap
metdata:
  name: app-config
data:
  APP_COLOR: blue
  APP_MODE: prod
-----
POD.yaml:
apiVersion: v1
kind: Pod
metdata:
  name: simple-webapp
  labels: 
    name: simple-webapp
spec:
  containers:
  - name: simple-webapp
    image: simple-webapp
    ports:
      - containerPort: 8080
    envFrom:
      - configMapRef:
            name: app-config

OR
    env:
      - name: APP_COLOR
        valueFrom:
          configMapKeyRef:
            name: app-config
            key: APP_COLOR
----
InitContainer:

apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox
    command: ['sh', '-c', 'git clone <some-repository-that-will-be-used-by-application> ;']

-------------
Cluster Management

# Move the pods to another node before making it unavailable
kubectl drain node-01

# Mark the node as unscheduleable
kubectl cordon node-01

# Cancel and bring node to be avlable and schedulable
kubectl uncordon node-01

# Get pods on node
kubectl get pods -o wide --field-selector spec.nodeName=node01

# kubeadm - Get the latest stable version available for upgrade
kubeadm upgrade plan

systemctl daemon-reload
---------
Backup
(Resource Configuration)
kubectl get all -all-namespaces -o yaml >back.yaml

(cluster-configuration)
etcdctl \
  snapshot save snapshot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.cert \
  --cert=/etc/etcd/etcd-server.crt \
  --key=/etc/etcd/etcd-server.key

EXAMPLE: *****
etcdctl \
  snapshot save /opt/snapshot-pre-boot.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key


etcdctl  --data-dir /var/lib/etcd-from-backup snapshot restore /opt/snapshot-pre-boot.db
etcdctl snapshot status snapshot.db
export ETCDCTL_API=3

vim /etc/kubernetes/manifests/etcd.yaml
  - hostPath:
      path: /var/lib/etcd-from-backup
      type: DirectoryOrCreate
***********************

Restore:
service kube-apiserver stop
etcdctl snapshot restore snapshot.db --data-dir=/var/lib/etcd-from-backup
* update etcd.service file with the restore path of data-dir
systemctl daemon-reload
service kube-apiserver start

---------------
Manage Clusters:
kubectl config use-context cluster1
--------------

Security:
There are different authentication methods for authenticate with the kube-apiserver:
users:
(Not recommanded - Noth available on v1.19)
create a csv file users-file.csv
pass1,user1,u0001
pass2,user2,u0002

On the kube-apiser.service add the option --basic-auth-file=user-detail.csv
(Same for user-token-details.csv) and replace the password with a token.

Service Account:
External:
An account (Like promiteus, jenkins) to communicate with the cluster API.
Once a Service Account is created, it creates a token automatically.
This TOKEN should be added to the external resource
* The secret stored in "secret" object.

Internal:
Built in token (default ServiceAccount)

-------------------
Private Repository:

kubectl create secret docker-registry regcred\
  --docker-server=private-registry.io\
  --docker-username=registry-user\
  --docker-password=registry-password\
  --docker-email=aharon.nadav@email.com

pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: private-registry.io/apps/internal-app
  imagePullSecrets:
  - name: regcred


# Set user on the POD:
pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  securityContext:
    runAsUser: 1000
  containers:
  - name: nginx
    image: private-registry.io/apps/internal-app
  imagePullSecrets:
  - name: regcred

# Set user on the Container:
pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
  - name: nginx
    image: private-registry.io/apps/internal-app
    command: ["sleep","60"]
    securityContext:
      runAsUser: 1000
      capabilities:
        add: ["MAC_ADMIN"]
  imagePullSecrets:
  - name: regcred

------------------------------
# Network Policy
(Suuport 3rd party - Calico)

external   1/1     Running   0          8m29s
internal   1/1     Running   0          8m29s
mysql      1/1     Running   0          8m29s
payroll    1/1     Running   0          8m29s

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector: #rule1
      matchLabels:
        name: api-prod
      namespaceSelector: #Optional + Adding "-" will make it a rule that allows to all pods under NS prod and not only to POD api-prod
        matchLabels:
          name: prod
      - ipBlock: #Optional #Rule2
          cidr: 192.168.5.10/32
    ports:
    - protocol: TCP
      port: 3306
  egress:
  - to:
    - ipBlock:
      cidr: 192.468.5.11/32
    ports:
    - protocol: TCP
      port 80

-------------------
# Storage
#Docker
docker volume create data_volume
#Creates a folder to be mounted by docker.   
/var/lib/docker/volumes/data_volume

docker run -v data_volume:/var/lib/mysql mysql

#Using any local folder
docker run -v /data/mysql:/var/lib/mysql mysql

#New method on docker:
docker run \
--mount type=bind,source=/data/mysql,target=/var/lib/mysql mysql

# Use EBS Docker
docker run -it \
--name mysql --volume-driver rexray/ebs --mount src=ebs-vol,target=/var/lib/mysql mysql

# Volumes:
apiVersion: v1
kind: Pod
metadata:
  name: random-number-generator
spec:
  containers:
  - name: alpine
    image: alpine
    command: ["/bin/sh","-c"]
    args: ["shuf -i o-100 -n 1 >> /opt/number.out"]
    volumeMounts:
    - mountPath: /opt
      name: data-volume
# For local store
  volumes:
  - name: data-volume
    hostPath:
      path: /data
      type: Directory
# AWS Volume Store
  volumes:
  - name: data-volume
    awsElasticBlockStore:
      volumeID: <volume-id>
      fsType: ext4

# Persistent Volumes
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-voll
spec:
  accessModes:
    - ReadWriteOnce #ReadOnlyMany/ReadWriteOnce/ReadWriteOnce
  capacity:
    storage: 1Gi
  
  #Local
  hostPath:
    path: /tmp/data
  #Web
  awsElasticBlockStore:
    volumeID: <volume-id>
    fsType: ext4

# Persisten Volume Claim
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi

Example:
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  containers:
  - name: event-simulator
    image: kodekloud/event-simulator
    env:
    - name: LOG_HANDLERS
      value: file
    volumeMounts:
    - mountPath: /log
      name: log-volume

  volumes:
  - name: log-volume
    persistentVolumeClaim:
      claimName: claim-log-1

# Storage Class
The Storage Class (Dynamic Provisioning), creates the volume on the vendor (AWS/GCP/etc) automatically and attach to pod when it creates.

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: google-storage
provisioner: kubernetes.io/gce-pd
#volumeBindingMode: WaitForFirstConsumer
----
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: google-storage
  resources:
    requests:
      storage: 500Mi

----
kind: Pod
metadata:
  name: webapp
spec:
  containers:
  - name: event-simulator
    image: kodekloud/event-simulator
    env:
    - name: LOG_HANDLERS
      value: file
    volumeMounts:
    - mountPath: /log
      name: log-volume

  volumes:
  - name: log-volume
    persistentVolumeClaim:
      claimName: claim-log-1

-------------------
# Networking

- Create network namespace
ip nets add red
ip nets add blue

#Connect network between different namespaces
ip link add veth-red type veth peer name veth-blue

#Connect a veth to namespace
ip link set veth-red netns red
ip link set veth-blue netns blue
//
ip -n red link del veth-red

#Assign an IP to the namespace
ip -n red addr add 192.168.15.1 dev veth-red
ip -n blue addr add 192.168.15.2 dev veth-blue

ip -n red link set veth-red up
ip -n blue link set veth-blue up

# Kubernetes Switch - Connect multiple namespaces
ip link add v-net-0 type bridge
ip link set dev v-net-0 up

ip link add veth-red type veth peer name veth-red-br
ip link add blue-red type veth peer name veth-blue-br

ip link set veth-red addr red nets red
ip link set veth-red-br master v-net-0 
ip link set veth-blue addr  blue nets blue
ip link set veth-blue-br master v-net-0 

ip -n red addr add 19.268.15.1 dev veth-red
ip -n blue addr add 19.268.15.2 dev veth-blue

ip -n red link set veth-red up
ip -n blue link set veth-blue up

#Add localhost to the switch to allow communication between the host to the namespace
ip addr add 192.165.5.14/24 dev v-net-0

#Add NAT
iptables -t nat -A POSTROUTING -s 192.168.15.0/24 -j MASQUERADE

#Add Default Gateway
ip netns exec blue ip route add default via 192.168.15.5

# Docker Networking
None Network:
The docker container will not be able to reach the internet and the containers will not be able to communicate between each other.

docker run --network none nginx

Host Network:
Allowd communication between the host and the container.
The containers still cannot communicate between each other and cannot use the same port for the app as it use the host port, for example: 80 WEB ACCESS

docker run --network host nginx

# Kubernetes Ports:
etcd 2380
kube-api 6443
kubelet  10250
kube-scheduler 10251
kube-controller-manager 10252

node service 30000-32767

# Pod Networking
When a container is created, the KUBELET automatically configuring the network settings.
The configurations paths are:
--cni-conf-dir=/etc/cni/net.d (All the plugins)
--cni-bin-dir=/etc/cni/bin (All the configurations files)
and running ./net-script.sh with the ip add and ip route commands.


# Weaveworks - Manage K8s network application
Deploy:
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

update ip range:
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=10.50.0.0/16"

-----------
# Ingress
Format - kubectl create ingress <ingress-name> --rule="host/path=service:port"

Example - kubectl create ingress ingress-test --rule="wear.my-online-store.com/wear*=wear-service:80" 

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
  namespace: critical-space
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - http:
      paths:
      - path: /pay
        backend:
          serviceName: pay-service
          servicePort: 8282

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
  name: rewrite
  namespace: default
spec:
  rules:
  - host: rewrite.bar.com
    http:
      paths:
      - backend:
          serviceName: http-svc
          servicePort: 80
        path: /something(/|$)(.*)

# Service Ingree by command
kubectl expose -n ingress-space deployment ingress-controller --type=NodePort --port=80 --name=ingress --dry-run=client -o yaml > ingress.yaml

apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  name: ingress
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    name: nginx-ingress
  type: NodePort
status:
  loadBalancer: {}

------------
# Troubleshooting

* ControlPlane
service kube-apiserver status
service kube-controller-manager status
service kube-scheduler status
service kubelet status(Node)
kubectl logs kube-apiserver-master -n kube-system
journalctl -u kube-apiserver
journalctl -u kubelet -f (From node)
 - Settings: /var/lib/kubelet/config.yaml

kubectl describe node worker-1
kubectl get pods -n kube-system
kubectl logs controll-pod kube-system
** /etc/kubernetes + /etc/kuberneter/manifest

* Service
get pod label = kubectl describe pod mysql -nsomenamespace | grep Label
  Label=mysql
kubectl describe service -nsomenamespace -- check the selector

# Advanced kubectl commands
#Extra data
kubectl get nodes -o wide

#Filter
kubectl get pods -o json
kubectl get pods -o=jsonpath='{ .items[0].spec.containers[0].image}'

#3 commands to print output as a table

#Formating
kubectl get pods -o=jsonpath='{.items[*].metadata.name}{"\n"}{.items[*].status.capcity.cpu}'

#Pretty Formating with a loop
kubectl get nodes -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.capacity.cpu}{"\n"}{end}}'

OR

kubectl get nodes -o=custom-columns=<COLUMN NAME>:<JSON PATH>
kubectl get nodes -o=custom-columns=NODE:.metadata.name ,CPU:.status.cpu

#Sort
kubectl get nodes --sort-by=.metadata.name
kubectl get nodes --sort-by=.status.capacity.cpu

# TIPS
Check the password inside the deployment
Check the password on the pod description

