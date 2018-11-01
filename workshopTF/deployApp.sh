#!/bin/bash

# # --- Configure variables ---
# export DBNAME="${TF_VAR_autonomous_database_db_name}"

# export REGION=$(cat $HOME/.oci/config | grep region= | sed -e 's/region=//')

# if [ "${REGION}" = "us-ashburn-1" ]
# then
#     export OCIR="iad.ocir.io"
# elif [ "${REGION}" = "us-phoenix-1" ]
# then
#     export OCIR="phx.ocir.io"
# fi

# export TENANCYOCID=$(cat $HOME/.oci/config | grep tenancy= | sed -e 's/tenancy=//')
# export USEROCID=$(cat $HOME/.oci/config | grep user= | sed -e 's/user=//')
# export TENANCY=$(oci iam compartment get --compartment-id "${TENANCYOCID}" --query "data.name" |  sed 's/"//g')
# export USERNAME=$(oci iam user get --user-id "${USEROCID}" --query "data.name" |  sed 's/"//g')


# if [ "${AUTHTOKEN}" == "" ]
# then
#     export AUTHTOKEN=$(oci iam auth-token create --description "token for OCIR" --user-id "${USEROCID}"  --query "data.token" |  sed 's/"//g')
# fi

# echo "ocir: " $OCIR
# echo "tenancy name: " $TENANCY
# echo "user name: " $USERNAME
# echo "auth token" $AUTHTOKEN


# # ---- Configure with sqlplus ----

# # if [  ! -f "/opt/oracle/database/wallet/Wallet_*" ]
# # then
# #   echo "missing wallet zip, download wallet from database console and copy to database/wallet folder"
# #   /bin/bash
# #   exit
# # fi

# cd /opt/oracle/database/wallet
# unzip Wallet*.zip
# cat >sqlnet.ora<< EOL
# WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="${TNS_ADMIN}")))
# SSL_SERVER_DN_MATCH=yes
# EOL
# cd /opt/oracle
# sqlplus admin/OpenW0rldD3mo@${DBNAME}_HIGH @create_schema.sql; &&

# # TODO when aOne repo is out of workshop folder
# # git clone https://github.com/cloudsolutionhubs/aOne-oow.git

# # copy database folder with configs to aOne app
# mkdir -p /opt/oracle/aOne-oow/database/wallet
# cp -r /opt/oracle/database/wallet /opt/oracle/aOne-oow/database/wallet

# # copy instant client to aOne
# cp /opt/oracle/database/downloads/oracle-instantclient18.3-basic-18.3.0.0.0-1.x86_64.rpm /opt/oracle/aOne-oow/


# # --------------------- Build aOne container ---------------------

# echo "${AUTHTOKEN}" | docker login $OCIR -u $TENANCY/$USERNAME --password-stdin &&

# TODO when finished

docker build -t $OCIR/$TENANCY/$USERNAME/aone:latest /opt/oracle/aOne-oow/ &&


# --------------------- Deploy aOne image to OCIR ------------

docker push $OCIR/$TENANCY/$USERNAME/aone:latest &&

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
        image: $OCIR/$TENANCY/$USERNAME/aone:latest
        imagePullPolicy: Always
        env:
        - name: username 
          value: "admin"
        - name: password
          value: "OpenW0rldD3mo"
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
    port: 80
    targetPort: 8080
  selector:
    app: aone
EOL

# ------------------------- Deploy app ----------------------
kubectl apply -f /opt/oracle/k8s-deployment.yaml


# ------------------------ Check for ip address of service ----


while true
do
    RESULT=$(kubectl get service aone-service -o=jsonpath="{.status.loadBalancer.ingress[0].ip}")
    if [ "" != "${RESULT}" ]
        then 
            echo "Your app is up and running at http://${RESULT}:80"
            break
    else
        echo "waiting for service to come up"
        sleep 5
    fi
done