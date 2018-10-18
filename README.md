

# Prereqs
- make sure you have an oci user that has admin rights to manange all resources in a given comparment
- collect the following details
    - tenancy OCID
    - User OCID
    - fingerprint
    - path of private key 
    - region
    - compartment ocid

# Step 1
- build the docker image
```
cd workshop
docker build -t worker .
```

- Start the container
```
docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v `pwd`/database/wallet:/opt/oracle/database/wallet worker /bin/bash
```

- setup oci config files
```
oci setup config
```
    - accept all defaults
    - enter USEROCID
    - enter tenancyOCID
    - enter region

- copy the public key and paste into the user api key page
```
cat ~/.oci/oci_api_key_public.pem
```

- deploy infra
```
source deployInfra.sh
```

- enter compartment ocid
- watch all the resources needed deploy automatically

- Download Wallet onto host machine to database/wallet folder
```
mv ~/Downloads/Wallet*.zip ./database/wallet/
```

- deploy the app to the cluster
```
source deployApp.sh
```