#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: ./build.sh lambdaName"
    exit 1
fi

# Assign the first argument to lambda variable
lambda=${1%/}
echo "Deploying $lambda:"

# Navigate to the lambda directory
cd "$lambda" || { 
    echo "Couldn't cd to directory $lambda. You may have mis-spelled the lambda/directory name."
    exit 1
}

# Run npm install
echo "npm installing..."
npm install
if [ $? -eq 0 ]; then
    echo "npm install completed successfully."
else
    echo "npm install failed."
    exit 1
fi

# Check if aws-cli is installed
echo "Checking that aws-cli is installed..."
which aws > /dev/null
if [ $? -eq 0 ]; then
    echo "aws-cli is installed, continuing..."
else
    echo "You need aws-cli to deploy this lambda. Google 'aws-cli install'"
    exit 1
fi

echo "removing old zip"
rm archive.zip;
echo "creating a new zip file"
zip -r archive.zip * -x '*.git/*' 'tests/*' 'node_modules/aws-sdk/*' '*.zip'

echo "Uploading $lambda to AWS Lambda"

# Ensure that role ARN is correctly defined with no missing spaces between arguments
aws lambda create-function \
    --function-name $lambda \
    --runtime nodejs18.x \
    --role arn:aws:iam::779846825244:role/service-role/lambdaBasic \
    --handler index.handler \
    --zip-file fileb://archive.zip \
    --publish

# Check if the function creation was successful
if [ $? -eq 0 ]; then
    echo "!! Create Successful !!"
    exit 1
fi

# If function already exists, update the function code
aws lambda update-function-code \
    --function-name $lambda \
    --zip-file fileb://archive.zip \
    --publish

# Check if update was successful
if [ $? -eq 0 ]; then
    echo "!! Update Successful !!"
else
    echo "Upload failed"
    echo "If the error was a 400, check that there are no slashes in your lambda name"
    echo "Lambda name = $lambda"
    exit 1
fi