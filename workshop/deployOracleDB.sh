#!/bin/bash

export DBNAME="owdb${RANDOM}"
echo "${DBNAME}" >> /opt/oracle/database/dbname.txt

export DB_PASSWORD="0PenW0rldD3mo"


if [ "${OCIDB}" == "" ]
    then
    export OCIDB=$(oci db autonomous-database create --compartment-id "${COMPARTMENTOCID}" --admin-password "${DB_PASSWORD}" --cpu-core-count "1" --data-storage-size-in-tbs "1" --db-name "${DBNAME}" --display-name "${DBNAME}" --license-model "LICENSE_INCLUDED" --wait-for-state "AVAILABLE" --query "data.id" |  sed 's/"//g') &&
    echo "completed deploying autonoumous-database"
fi

if [ "${OCIDB}" == "" ]
    then
    echo "error creating atp database"
fi

# TODO get OCIDB ocid
mkdir -p /opt/oracle/database/wallet

oci db autonomous-database generate-wallet --autonomous-database-id "${OCIDB}" --password "${DB_PASSWORD}" --file /opt/oracle/database/wallet/wallet.zip

# ---- Configure with sqlplus ----
# if [ ! -f "/opt/oracle/database/dbname.txt" ]
# then
#   echo "please run `source deployInfra.sh` first"
#   /bin/bash
#   exit
# fi

# if [  ! -f "/opt/oracle/database/wallet/Wallet_*" ]
# then
#   echo "missing wallet zip, download wallet from database console and copy to database/wallet folder"
#   /bin/bash
#   exit
# fi

cd /opt/oracle/database/wallet
# check why unzip wallet wont work
unzip wallet.zip
ls /opt/oracle/database/wallet
cat >sqlnet.ora<< EOL
WALLET_LOCATION = (SOURCE = (METHOD = file) (METHOD_DATA = (DIRECTORY="${TNS_ADMIN}")))
SSL_SERVER_DN_MATCH=yes
EOL
cd /opt/oracle
sqlplus admin/${DB_PASSWORD}@${DBNAME}_HIGH @create_schema.sql;

# TODO when aOne repo is out of workshop folder
# git clone https://github.com/cloudsolutionhubs/aOne-oow.git
mkdir -p /opt/oracle/aOne-oow/database/wallet
cp -r /opt/oracle/database /opt/oracle/aOne-oow
