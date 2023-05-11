#!/bin/bash
#sourcing file with terraform_init function
source ~/fun.sh
# extract image version defined in package.json 
image_version=$(sed -n 's/.*"version": *"\([^"]*\).*/\1/p' ../package.json)

if [ "$1" == "update" ]
then
    doppler --project rasbign --config dev_client run --name-transformer tf-var  -- terraform destroy -var="image_version=$image_version" -target=google_api_gateway_gateway.api_gw -auto-approve
    doppler --project rasbign --config dev_client run --name-transformer tf-var  -- terraform apply -var="image_version=$image_version" -auto-approve
    exit 0
fi

if [ "$1" == "init" ]
then 
    # get credentials, login to terraform
    terraform_init
fi

doppler --project rasbign --config dev_client run --name-transformer tf-var  -- terraform "$1" -var="image_version=$image_version"
