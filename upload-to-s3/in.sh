#!/bin/bash
set -eux
echo "Installing the aws cli"
apt-get update > /dev/null 2>&1
export DEBIAN_FRONTEND=noninteractive
apt-get install awscli -yq vim  > /dev/null 2>&1
export AWS_ACCESS_KEY_ID=$access_key_id
export AWS_SECRET_ACCESS_KEY=$secret_access_key
aws --endpoint-url=https://${endpoint} s3 cp s3://${bucket}/${bucket_name}/${tile_name} --no-verify-ssl
aws --endpoint-url=https://${endpoint} s3 ls s3://${bucket}/${bucket_name}/ --no-verify-ssl
ls -ltr
