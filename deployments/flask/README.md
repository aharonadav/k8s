https://www.vantage-ai.com/blog/deploy-a-flask-api-in-kubernetes

Creating secrets
Kubernetes has it’s own method of dealing with your sensitive information by configuring Kubernetes Secrets. This can be done with a simple YAML file. These secrets can be accessed by any pod in your cluster by specifying environment variables (which we will see later on). Secrets should be specified as base64-encoded strings. So first we have to get the encoded version of your password via your terminal: echo -n <super-secret-passwod> | base64. Copy the output and embed it in the following secrets.yml file at the db_root_password field. The metadata.name field is important as we have to specify this in a later stage, so be sure to remember it

---
apiVersion: v1
kind: Secret
metadata:
  name: flaskapi-secrets
type: Opaque
data:
  db_root_password: <Insert your password here>
view rawsecrets.yml hosted with ❤ by GitHub
You can now add the secrets to your cluster via your terminal: kubectl apply -f secrets.yml . And see if it worked by checking the secrets via kubectl get secrets.

Persistent volume
A persistent volume is a storage resource with a lifecycle independent of a Pod. This means that the storage will persist if a pod goes down. As Kubernetes has the permission to restart pods at any time, it is a good practice to set your database storage to a persistent volume. A persistent volume can be a directory on your local filesystem, but also a storage service of a cloud provider (for example AWS Elastic Block Storage or Azure Disk). The type of the persistent volume can be specified when creating the persistent volume. For this tutorial you will use a hostPath type, which will create a volume on your minikube node. However, make sure to use another type (see the documentation) in a production environment as your data will be lost if you delete your minikube node when using a hostPath type.

Making your application use a persistent volume exists of two parts:
1. Specifying the actual storage type, location, size and properties of the volume.
2. Specify a persistent volume claim that requests a specific size and access modes of the persistent volume for your deployments.

Create a persistent-volume.yml file and specify the size (in this example 2GB), access modes and the path the files will be stored. The spec.persistentVolumeReclaimPolicy specifies what should be done if the persistent volume claim is deleted. In the case of a stateful application like the MySQL database, you want to retain the data if the claim is deleted, so you can manually retrieve or backup the data. The default reclaim policy is inherited from the type of persistent volume, so it is good practice to always specify it in the yml file.

apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "/mnt/data"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
view rawpv.yml hosted with ❤ by GitHub
 
Again you can add the storage via kubectl apply -f persistent-volume.yml . And see if the details of your created resources via kubectl describe pv mysql-pv-volume and kubectl describe pvc mysql-pv-claim. As you made a hostPath type persistent volume, you can find the data by logging into the minikube node minikube ssh and navigate to the spcified path (/mnt/data).

Deploy the MySQL server
With our secrets and persistent volume (claim) in place, we can start building our application. First we will deploy a MySQL server. Pull the latest mysql imagedocker pull mysql and create the mysql-deployment.yml file. There are several things worth mentioning about this file. We specify that we only spin-up one pod (spec.replicas: 1). The deployment will manage all pods with a label db specified by spec.selector.matchLabels.app: db . The templatefield and all it’s subfields specify the characteristics of the pod. It will run the image mysql, will be named mysql as well and looks for the db_root_password field in the flaskapi-secrets secret and will set the value to the MYSQL_ROOT_PASSWORD environment variable. Furthermore we specify a port that the container exposes and which path should be mounted to the persistent volume spec.selector.template.spec.containers.volumeMounts.mountPath: /var/lib/mysql . At the bottom we also specify a service also called mysql of the LoadBalancertype so we can access our database via this service.

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  labels:
    app: db
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
      - name: mysql
        image: mysql
        imagePullPolicy: Never
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: flaskapi-secrets
              key: db_root_password
        ports:
        - containerPort: 3306
          name: db-container
        volumeMounts:
          - name: mysql-persistent-storage
            mountPath: /var/lib/mysql
      volumes:
        - name: mysql-persistent-storage
          persistentVolumeClaim:
            claimName: mysql-pv-claim


---
apiVersion: v1
kind: Service
metadata:
  name: mysql
  labels:
    app: db
spec:
  ports:
  - port: 3306
    protocol: TCP
    name: mysql
  selector:
    app: db
  type: LoadBalancer
view rawmysql-deployment.yml hosted with ❤ by GitHub
 
You can now deploy the MySQL server with kubectl apply -f mysql-deployment.yml. And see if a pod is running via kubectl get pods.

Create database and table
The last thing we have to do before implementing the API is initializing a database and schema on our MySQL server. We can do this using multiple methods, but for the sake of simplicity let’s access the MySQL server via the newly created service. As the pod running the MySQL service is only accessible from inside the cluster, you will start up a temporary pod that serves as mysql-client:
1. Set up the mysql-client via the terminal: kubectl run -it --rm --image=mysql --restart=Never mysql-client -- mysql --host mysql --password=<your_password>. Fill in the (decoded) password that you specified in the secrets.yml file.
2. Create the database, table and schema. You can do whatever you like, but to make sure the sample Flask app will work do as follows:
CREATE DATABASE flaskapi;
USE flaskapi;
CREATE TABLE users(user_id INT PRIMARY KEY AUTO_INCREMENT, user_name VARCHAR(255), user_email VARCHAR(255), user_password VARCHAR(255));

Deploying the API
Finally it is time to deploy your REST API. The following gist demonstrates an example of a Flask app that implements the API with only two endpoints. One for checking if the API functions and one for creating users in our database. In the GitHub repo you can find the python file that has endpoints for reading, updating and deleting entries in the database as well. The password for connecting to the database API is retrieved from the environment variables that were set by creating secrets. The rest of the environment variables (e.g MYSQL_DATABASE_HOST) is retrieved from the MySQL service that was implemented before (further on I will explain how to make sure the Flask app has access to this information).

"""Code for a flask API to Create, Read, Update, Delete users"""
import os
from flask import jsonify, request, Flask
from flaskext.mysql import MySQL

app = Flask(__name__)

mysql = MySQL()

# MySQL configurations
app.config["MYSQL_DATABASE_USER"] = "root"
app.config["MYSQL_DATABASE_PASSWORD"] = os.getenv("db_root_password")
app.config["MYSQL_DATABASE_DB"] = os.getenv("db_name")
app.config["MYSQL_DATABASE_HOST"] = os.getenv("MYSQL_SERVICE_HOST")
app.config["MYSQL_DATABASE_PORT"] = int(os.getenv("MYSQL_SERVICE_PORT"))
mysql.init_app(app)


@app.route("/")
def index():
    """Function to test the functionality of the API"""
    return "Hello, world!"


@app.route("/create", methods=["POST"])
def add_user():
    """Function to add a user to the MySQL database"""
    json = request.json
    name = json["name"]
    email = json["email"]
    pwd = json["pwd"]
    if name and email and pwd and request.method == "POST":
        sql = "INSERT INTO users(user_name, user_email, user_password) " \
              "VALUES(%s, %s, %s)"
        data = (name, email, pwd)
        try:
            conn = mysql.connect()
            cursor = conn.cursor()
            cursor.execute(sql, data)
            conn.commit()
            cursor.close()
            conn.close()
            resp = jsonify("User added successfully!")
            resp.status_code = 200
            return resp
        except Exception as exception:
            return jsonify(str(exception))
    else:
        return jsonify("Please provide name, email and pwd")
      
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
view rawflaskapi.py hosted with ❤ by GitHub
 
To deploy this app in your Kubernetes cluster you have to make an image of this Flask app by creating a simple Dockerfile. Nothing special, preparing your container, installing requirements, copying the folder content and running the Flask app. Go to the GitHub repo to find the Dockerfile and the requirements.txt file that is required for building the image. Before you can deploy the Flask app in the Kubernetes cluster, you first have to build the image and name it flask-api via docker build . -t flask-api.

FROM python:3.6-slim

RUN apt-get clean \
    && apt-get -y update

RUN apt-get -y install \
    nginx \
    python3-dev \
    build-essential

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt --src /usr/local/src

COPY . .

EXPOSE 5000
CMD [ "python", "flaskapi.py" ]
view rawDockerfile hosted with ❤ by GitHub
 
Now it is time to define the deployment and service for the Flask app that implements a RESTful API. The deployment will start up 3 pods (specified in the flaskapp-deployment.yml at the spec.replicas: 3 field) Within each of these pods a container is created from the flask-api image you just build. To make sure Kubernetes uses the locally built image (instead of downloading an image from an external repo like Dockerhub) make sure to set the imagePullPolicy to never. To make sure the Flask app can communicate with the database a few environment variables should be set. The db_root_password is retrieved from your created secrets. Each container that starts up inherits environmental variables with information of all running services, including IP and port addresses. So you don’t have to worry about having to specify the host and port of the MySQL database to the Flask app. Finally, you will define a service of the LoadBalancer type to divide the incoming traffic between the three pods.

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flaskapi-deployment
  labels:
    app: flaskapi
spec:
  replicas: 3
  selector:
    matchLabels:
      app: flaskapi
  template:
    metadata:
      labels:
        app: flaskapi
    spec:
      containers:
        - name: flaskapi
          image: flask-api
          imagePullPolicy: Never
          ports:
            - containerPort: 5000
          env:
            - name: db_root_password
              valueFrom:
                secretKeyRef:
                  name: flaskapi-secrets
                  key: db_root_password
            - name: db_name
              value: flaskapi

---
apiVersion: v1
kind: Service
metadata:
  name: flask-service
spec:
  ports:
  - port: 5000
    protocol: TCP
    targetPort: 5000
  selector:
    app: flaskapi
  type: LoadBalancer
view rawflaskapp-deployment.yml hosted with ❤ by GitHub
 
Making requests to the API
You are now ready to use our API and interact with your database. The last step is to expose the API service to the outside world via your terminal: minikube service flask-service. You will now see something like

 

Go to the provided URL and you will see the Hello World message, to make sure your API is running correctly. You can now interact with the API using your favorite request service like Postman or curl in your terminal. To create a user provide a json file with a name, email and pwd field. for example:curl -H "Content-Type: application/json" -d '{"name": "<user_name>", "email": "<user_email>", "pwd": "<user_password>"}' <flask-service_URL>/create. If you implemented the other methods of the API (as defined in the GitHub repo) as well, you may now be able to query all users in the database via: curl <flask-service_URL>/users.

Conclusion
In this hands-on tutorial you set up deployments, services and pods, implemented a RESTful API by deploying a Flask app and connected it with other micro-services (a MySQL database in this case). You can keep running this locally, or implement it on a remote server for example in the cloud and get it to production. Feel free to clone the repo and adjust the API as you like, or add additional micro-services.