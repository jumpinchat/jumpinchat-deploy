#!/bin/bash

mkdir -p /var/www/ && cd /var/www/

set -e

export AWS_ACCESS_KEY_ID="access key"
export AWS_SECRET_ACCESS_KEY="secret key"
export AWS_DEFAULT_REGION="us-east-1"


if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
  echo "aws access key not set" >&2
  exit 1
fi

if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
  echo "aws secret not set" >&2
  exit 1
fi

if [ -z "${AWS_DEFAULT_REGION}" ]; then
  echo "aws region not set" >&2
  exit 1
fi

aws s3 cp s3://jic-artifacts/jic-web.tar.gz jic-web.tar.gz

tar -xvzf jic-web.tar.gz
