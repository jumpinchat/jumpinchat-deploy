#!/bin/sh

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

if [ -z "${ENV}" ]; then
  echo "no environment to fetch" >&2
  exit 1
fi

DB="tc"
S3PATH="s3://jic-mongo-backups/$ENV/$DB/"
S3LATEST=$S3PATH"latest".dump.gz

aws s3 cp $S3LATEST - | mongorestore --host localhost --archive --gzip
