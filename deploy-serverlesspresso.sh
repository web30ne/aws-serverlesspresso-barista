#!/bin/bash

# STEP 0: IAM setup
aws iam create-user --user-name serverlesspresso-deployer
aws iam attach-user-policy --user-name serverlesspresso-deployer \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
aws iam create-access-key --user-name serverlesspresso-deployer
echo "Copy AccessKeyId & SecretAccessKey and run: aws configure"

# STEP 1: Clone repo
git clone https://github.com/aws-samples/serverless-coffee.git
cd serverless-coffee

# STEP 2: Deploy core stack
cd 00-baseCore
sam build
sam deploy --guided

# STEP 3: Deploy app microservices
cd ../01-appCore
sam build
sam deploy --guided

# STEP 4: Deploy EventPlayer (optional)
cd ../extensibility/EventPlayer
sam build
sam deploy --guided

# STEP 5: Emit a test event directly to EventBridge
aws events put-events --entries file://events.json

echo "Replace <API_URL> with ConfigServiceApi endpoint from CloudFormation outputs for curl calls."