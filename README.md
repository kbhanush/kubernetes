

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

- change to parent directory and start the container
```
cd ../
docker run -it -v /var/run/docker.sock:/var/run/docker.sock  -v `pwd`:/root worker /bin/bash
```

- setup oci config files
```
oci setup config
```
    - accept all defaults
    - enter USEROCID
    - enter tenancyOCID
    - enter region

- copy the public key and paste into the ocir user api key page
```
cat ~/.oci/oci_api_key_public.pem
```

- deploy infra
```
source deployInfra.sh
```

- enter compartment ocid
- watch all the resources needed deploy automatically and the web app deployed

- Download Wallet
- change to aOne directory
```
cd

- deploy the app to the cluster