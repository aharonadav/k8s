
Certificate Authority:
----------------------
openssl genrsa -out ca.key 2048
openssl req -new -key ca.key -subj "/CN=KUBERNETES-CA" -out ca.csr
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt


Client Certificate:
-------------------
* Same for kube-scheduler, kube-controller-manager, kube-proxy
* Admin certificate to control the master

openssl genras -out admin.key 2048
openssl req -new -key admin.key -subj "/CN=kube-admin/O=system:master" -out admin.csr
#sign certificate
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -out admin.crt

Server Certificate:
-------------------
* ETCD
openssl genras -out apiserver.key 2048
openssl req -new -key admin.key -subj "/CN=kube-apiserver" -out apiserver.csr
* In order to be able to use names for the api-server, such as: kubernetes, kubernetes.default, kubernetes.default.svc.cluster.local, etc.
Create a file "openssl.cnf" >
[req]
req_extenshions = v3_req
[v3_req]
basicConstraints = CA:FLASE
keyUsage = nonRepudiation,
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernets
DNS.2 = kubernets.default
DNS.3 = kubernets.default.svc
DNS.4 = kubernets.default.svc.cluster.local
IP.1 = 10.96.0.1
IP.2 = 172.17.0.87
>>>>
openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out apiserver.crt -extensions v3_req -extfile openssl.cnf -days 1000

-----------------------
KubeConfig
Clusetrs: Clusters list (prod, dev, etc)
Eusers: Admin, Dev user, prod user, etc
Context: Defines which user allowed to use the cluster
(Can also mention the default namespace to work in)
Admin@prod --> Is the connections between the user and the cluster.

To use that context, run the command: kubectl config --kubeconfig=/root/my-kube-config use-context research
To know the current context, run the command: kubectl config --kubeconfig=/root/my-kube-config current-context

kubectl config view
kubectl config use-context prod-userd@production