#!/bin/bash

# ---- Configure with sqlplus ----
cd database/wallet
unzip Wallet*.zip
cat >sqlnet.ora<< EOL
WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="${TNS_ADMIN}")))
SSL_SERVER_DN_MATCH=yes
EOL
cd ../../
sqlplus admin/${DB_PASSWORD}@${DBNAME}_HIGH @create_schema.sql;

# TODO when aOne repo is out of workshop folder
# git clone https://github.com/cloudsolutionhubs/aOne-oow.git

cp -r database aOne-oow/database


# --------------------- Build aOne container ---------------------

echo "ocir: " $OCIR
echo "tenancy name: " $TENANCY
echo "user name: " $USERNAME
echo "auth token" $AUTHTOKEN

echo "${AUTHTOKEN}" | docker login $OCIR -u $TENANCY/$USERNAME --password-stdin

# TODO when finished

docker build -t $OCIR/$TENANCY/aone:latest aOne-oow/


# --------------------- Deploy aOne image to OCIR ------------

docker push $OCIR/$TENANCY/aone:latest

# -------------------- Create k8s secret

kubectl create secret docker-registry ocirsecret --docker-server=$OCIR --docker-username="${TENANCY}/${USERNAME}" --docker-password="${AUTHTOKEN}" --docker-email="a@a.com"

# -------------------- Create k8s deployment and services file -----

cat > k8s-deployment.yaml << EOL
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aone-deployment
spec:
  selector:
    matchLabels: 
      app: aone
  replicas: 1
  template:
    metadata:
      labels:
        app: aone
    spec:
      containers:
      - name: app
        image: $OCIR/$TENANCY/aone:latest
        imagePullPolicy: Always
        env:
        - name: username 
          value: "admin"
        - name: password
          value: "${DB_PASSWORD}"
        - name: connectionstring
          value: "${DBNAME}_high"
        ports:
        - containerPort: 8080
      imagePullSecrets:
        - name: ocirsecret
---
apiVersion: v1
kind: Service
metadata:
  name: aone-service
spec:
  type: LoadBalancer
  ports:
  - name: app-port
    port: 8080
    targetPort: 8080
  selector:
    app: aone
EOL

# ------------------------- Deploy app ----------------------
kubectl apply -f k8s-deployment.yaml


# ------------------------ Check for ip address of service ----


while true
do
    RESULT=$(kubectl get service aone-service -o=jsonpath="{.status.loadBalancer.ingress[0].ip}")
    if [ "" != "${RESULT}" ]
        then 
            echo "Your app is up and running at http://${RESULT}:8080"
            break
    else
        echo "waiting for service to come up"
        sleep 5
    fi
done