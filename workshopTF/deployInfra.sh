#!/bin/bash

echo "enter compartmentocid: "
read compartmentocid
export TF_VAR_compartment_ocid="${compartmentocid}"

export TF_VAR_tenancy_ocid="$(cat $HOME/.oci/config | grep tenancy= | sed -e 's/tenancy=//')"
export TF_VAR_fingerprint="$(cat $HOME/.oci/config | grep fingerprint= | sed -e 's/fingerprint=//')"
export TF_VAR_private_key_path="$(cat $HOME/.oci/config | grep key_file= | sed -e 's/key_file=//')"
export TF_VAR_user_ocid="$(cat $HOME/.oci/config | grep user= | sed -e 's/user=//')"
export TF_VAR_autonomous_database_db_name="db${RANDOM}"
cd /opt/oracle/infrastructure
terraform init
terraform apply --auto-approve
cd /opt/oracle
export KUBECONFIG="/opt/oracle/infrastructure/generated/kubeconfig"