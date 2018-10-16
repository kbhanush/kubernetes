#!/bin/bash

if [ "${OCIDB}" == "" ]
    then
    export OCIDB=$(oci db autonomous-database create --compartment-id "${COMPARTMENTOCID}" --admin-password "${DB_PASSWORD}" --cpu-core-count "1" --data-storage-size-in-tbs "1" --db-name "${USERNAME}db" --display-name "${USERNAME}db" --license-model "LICENSE_INCLUDED" --wait-for-state "AVAILABLE" --query "data.id" |  sed 's/"//g') &&
    echo "completed deploying autonoumous-database"
fi

if [ "${OCIDB}" == "" ]
    then
    echo "error creating atp database"
    /bin/bash
    exit
fi

