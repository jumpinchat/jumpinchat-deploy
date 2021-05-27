#!/bin/sh

set -e
REPO_URI="<your docker repository goes here>"
TAG="latest"

if [ $# -lt 1 ]; then
  echo "Usage:\n
    $0 <image> (<tag>)" >&2
    exit 1
fi

IMAGE=$1

if [ $# -eq 2 ]; then
  TAG=$2
fi


docker push ${REPO_URI}/${IMAGE}:${TAG}
