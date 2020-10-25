#!/bin/bash

# environment name to lowercase
ENVIRONMENT=$(echo "$1" | tr '[:upper:]' '[:lower:]')
PROJECT=$(echo "$2" | tr '[:upper:]' '[:lower:]')

if [[ $ENVIRONMENT == "" ]]; then
  echo "No env name passed"
  exit
fi

if [[ $PROJECT == "" ]]; then
  echo "No project name passed"
  exit
fi

REGION=`aws configure get default.region`

if [[ $ENVIRONMENT == "" ]]; then
  echo "No environment name passed"
  exit
fi

# creates backend.tf file
echo "terraform {
  backend \"s3\" {
    bucket = \"${PROJECT}-${ENVIRONMENT}-state\"
    key    = \"terraform.tfstate\"
    region = \"${REGION}\"
    dynamodb_table = \"${PROJECT}-${ENVIRONMENT}-tf-locks\"
    encrypt = true
  }
}
" > backend.tf
