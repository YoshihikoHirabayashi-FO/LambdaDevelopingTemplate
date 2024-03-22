#!/bin/bash

# configure aws account
echo "AWS Access Key ID: test"
echo "AWS Secret Access Key: test"
echo "Default region name: us-east-1"
echo "Default output format: json"
aws configure --profile localstack

# create localstack docker container
docker-compose up -d

# create secrets manager secrets
if aws --endpoint-url=http://localhost:4566 \
       secretsmanager describe-secret \
       --secret-id "MySecret" \
       --no-cli-pager \
       --profile localstack 2>/dev/null; then

    aws --endpoint-url=http://localhost:4566 \
        secretsmanager update-secret \
        --secret-id "MySecret" \
        --secret-string '{"username":"myusername","password":"mypassword"}' \
        --no-cli-pager \
        --profile localstack
else
    aws --endpoint-url=http://localhost:4566 \
        secretsmanager create-secret \
        --name "MySecret" \
        --description "My credentials" \
        --secret-string '{"username":"myusername","password":"mypassword"}' \
        --no-cli-pager \
        --profile localstack
fi

# create s3 bucket
aws --endpoint-url=http://localhost:4566 \
    s3 mb s3://my-localstack-bucket \
    --no-cli-pager \
    --profile localstack

# finish
read -p "Press Enter to continue..."
