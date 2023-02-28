Question: Upgrade kubernetes version
kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=

kubectl drain <nodename>
apt-get update
apt-get install kubeadm=1.20.0-00 kubelet=1.20.00 kubectl=1.20.00
kubeadm upgrade plan
kubeadm upgrade node
kubeadm upgrade apply 1.20.0
systemctl kubelet restart
systemctl daemon-reload

$ kubectl -n admin2406 get deployment -o custom-columns=DEPLOYMENT:.metadata.name,CONTAINER_IMAGE:.spec.template.spec.containers[].image,READY_REPLICAS:.status.readyReplicas,NAMESPACE:.metadata.namespace --sort-by=.metadata.name > /opt/admin2406_data

Make sure the port for the kube-apiserver is correct. Change port from 4380 to 6443.

# Upgrade image in deployment
kubectl set image deployment/gold-nginx nginx=nginx:1.17
$ kubectl set image deployment/nginx-deploy nginx=nginx:1.17 --record

kubectl expose pod messaging --name=messaging-service --port=6379 --protocol=TCP --type=ClusterIP --labels='tier=msg'

ETCDCTL_API=3 etcdctl snapshot save /opt/etcd-backup.db --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: use-pv
  name: use-pv
spec:
  volumes:
  - name: pv-1-storage
    persistentVolumeClaim:
      claimName: my-pvc
  containers:
  - image: nginx
    name: use-pv
    volumeMounts:
      - mountPath: "/data"
        name:pv-1-storage
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: redis-storage
  name: redis-storage
spec:
  containers:
  - image: redis:alpine
    name: redis-storage
    volumeMounts:
    - mountPath: /data/redis
      name: redis-volume
  volumes:
  - name: redis-volume
    emptyDir: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}


Create a nginx pod called nginx-resolver using image nginx, expose it internally with a service called nginx-resolver-service.

Test that you are able to look up the service and pod names from within the cluster. Use the image busybox:1.28 to create a pod for dns lookup. Record results in /root/CKA/nginx.svc and /root/CKA/nginx.pod for service and pod name resolutions respectively

Pod: nginx-resolver created

Service DNS Resolution recorded correctly

Pod DNS resolution recorded correctly

# Static pod
ssh my-node1
mkdir -p /etc/kubernetes/manifests/
cat <<EOF >/etc/kubernetes/manifests/static-web.yaml
apiVersion: v1
kind: Pod
metadata:
  name: static-web
  labels:
    role: myrole
spec:
  containers:
    - name: web
      image: nginx
      ports:
        - name: web
          containerPort: 80
          protocol: TCP
EOF



Questio:

Solution:
---
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: super-user-pod
  name: super-user-pod
spec:
  containers:
  - command:
    - sleep
    - "4800"
    image: busybox:1.28
    name: super-user-pod
    securityContext:
      capabilities:
        add: ["SYS_TIME"]
  dnsPolicy: ClusterFirst
  restartPolicy: Always

Question:
A pod definition file is created at /root/CKA/use-pv.yaml. Make use of this manifest file and mount the persistent volume called pv-1. Ensure the pod is running and the PV is bound.

mountPath: /data
persistentVolumeClaim Name: my-pvc

Solution:
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
       storage: 10Mi

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: use-pv
  name: use-pv
spec:
  containers:
  - image: nginx
    name: use-pv
    volumeMounts:
    - mountPath: "/data"
      name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: my-pvc       

Question:
Create a nginx pod called nginx-resolver using image nginx, expose it internally with a service called nginx-resolver-service.

Test that you are able to look up the service and pod names from within the cluster. Use the image busybox:1.28 to create a pod for dns lookup. Record results in /root/CKA/nginx.svc and /root/CKA/nginx.pod for service and pod name resolutions respectively

Solution:
kubectl run nginx-resolver --image=nginx
kubectl expose pod nginx-resolver --name=nginx-resolver-service --port=80 --target-port=80 --type=ClusterIP

kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service
kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup nginx-resolver-service > /root/CKA/nginx.svc

kubectl get pod nginx-resolver -o wide
kubectl run test-nslookup --image=busybox:1.28 --rm -it --restart=Never -- nslookup <P-O-D-I-P.default.pod> > /root/CKA/nginx.pod


Question:
Create a static pod on node01 called nginx-critical with image nginx and make sure that it is recreated/restarted automatically in case of a failure.

Use /etc/kubernetes/manifests as the Static Pod path for example.

kubectl run nginx-critical --image=nginx --dry-run=client -o yaml > static.yaml

root@controlplane:~# scp static.yaml node01:/root/

root@controlplane:~# kubectl get nodes -o wide

# Perform SSH
root@controlplane:~# ssh node01
OR
root@controlplane:~# ssh <IP of node01>

On node01 node:
Check if static pod directory is present which is /etc/kubernetes/manifests, if it's not present then create it.

root@node01:~# mkdir -p /etc/kubernetes/manifests

Add that complete path to the staticPodPath field in the kubelet config.yaml file.
root@node01:~# vi /var/lib/kubelet/config.yaml

now, move/copy the static.yaml to path /etc/kubernetes/manifests/.
root@node01:~# cp /root/static.yaml /etc/kubernetes/manifests/



