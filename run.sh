#!/bin/sh -v

# -----------------------------------------------------------------
# Configure the AWS CLI to let it communicate with your account
# -----------------------------------------------------------------
aws configure set aws_access_key_id $ACCESS_KEY_ID
aws configure set aws_secret_access_key $SECRET_ACCESS_KEY
aws configure set region us-east-1


# -----------------------------------------------------------------
# Delete any old deployments
# -----------------------------------------------------------------
# 1. Trigger CloudFormation stack delete
# 2. Wait for the stack to be deleted 
aws cloudformation delete-stack --stack-name  EducativeCourseApiGateway
aws cloudformation wait stack-delete-complete --stack-name EducativeCourseApiGateway


# -----------------------------------------------------------------
# With everything ready, we initiate the CloudFormation deployment.
# -----------------------------------------------------------------
aws cloudformation deploy \
    --template-file template.yml \
    --stack-name EducativeCourseApiGateway \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides Phone="$Phone" \
    --region us-east-1

# -----------------------------------------------------------------
# Get the API ID of the Rest API we just created.
# -----------------------------------------------------------------
apiId=`aws cloudformation list-stack-resources --stack-name EducativeCourseApiGateway | jq -r ".StackResourceSummaries[2].PhysicalResourceId"`
echo "API ID: $apiId"

# -----------------------------------------------------------------
# This is the URL for the API we just created
# -----------------------------------------------------------------
url="https://${apiId}.execute-api.us-east-1.amazonaws.com/v1"
echo $url

# -----------------------------------------------------------------
# Invoke POST to send message to the topic
# -----------------------------------------------------------------
curl --location --request POST $url --header 'Content-Type: application/json' --data-raw '{ "message": "Hello World" }'

# -----------------------------------------------------------------
# Check your phone for a text message
# -----------------------------------------------------------------
