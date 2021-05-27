#!/bin/bash

if [ -z "${ENV}" ]; then
  echo "ENV not set" >&2
  exit 1
fi

DB="tc"
S3PATH="s3://jic-mongo-backups/$ENV/$DB/"
S3BACKUP=${S3PATH}`date +"%Y%m%d_%H%M%S"`.dump.gz
S3LATEST=${S3PATH}"latest".dump.gz

/usr/bin/mongodump -h localhost -d ${DB} --excludeCollection=app_sessions --gzip --archive | \
  aws s3 cp - ${S3BACKUP}

echo "backed up to ${S3BACKUP}"

aws s3 cp ${S3BACKUP} ${S3LATEST}
