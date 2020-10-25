#!/bin/bash

# environment & project name to lowercase
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
BUCKET_NAME="${PROJECT}-${ENVIRONMENT}-state"
LOCKS_TABLE="${PROJECT}-${ENVIRONMENT}-tf-locks"

echo "caller identity:" 
aws sts get-caller-identity
echo "region:" $REGION
echo "environment:" $ENVIRONMENT
echo -n "Is the AWS identity correct? [yes/no]: "
read ans

if  [[ "$ans" != "yes" ]]; then
  exit
fi

aws dynamodb create-table \
    --region $REGION \
    --table-name ${LOCKS_TABLE} \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1

aws s3api create-bucket \
    --region $REGION \
    --create-bucket-configuration LocationConstraint=$REGION \
    --bucket ${BUCKET_NAME}

aws s3api put-bucket-versioning \
    --region $REGION \
    --bucket ${BUCKET_NAME} \
    --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
    --region $REGION \
    --bucket ${BUCKET_NAME} \
    --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

aws s3api put-public-access-block \
    --region $REGION \
    --bucket ${BUCKET_NAME} \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
  
# runs prepare_backend script - creates config for remote state
sh ./prepare_backend.sh $ENVIRONMENT

# creates tfvars directory if not exists yet
mkdir -p tfvars

# check if rule for file encryption for environment already exists
if [[ `cat .sops.yaml | grep "tfvars/${ENVIRONMENT}.tfvars"` != "" ]]; then
  echo "encrypted file rule already exists"
  exit
fi

# creates new encryption key
KEY_ARN=`aws kms create-key --description "SOPS ${ENVIRONMENT}" | grep -i "arn" | tr -s " " | cut -f3 -d " " | sed 's/,//g'`

# inserts new SOPS creation rule
echo "  - path_regex: tfvars/${ENVIRONMENT}.tfvars
    kms: ${KEY_ARN}" >> .sops.yaml
