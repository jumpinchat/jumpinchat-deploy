#!/bin/sh

set -e

IMAGE_NAME=$1

if [ $# -ne 1 ]; then
  echo "Usage:\n
    $0 <image name>" >&2
    exit 1
fi

docker-compose build --no-cache ${IMAGE_NAME}
docker-compose up -d
docker-compose ps
