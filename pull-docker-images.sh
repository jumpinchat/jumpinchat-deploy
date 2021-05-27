#!/bin/sh

set -e
REPO_URI="<your docker repository goes here>"

docker pull ${REPO_URI}/web
docker pull ${REPO_URI}/home
docker pull ${REPO_URI}/janus
docker pull ${REPO_URI}/nginx
docker pull ${REPO_URI}/mongodb
docker pull ${REPO_URI}/jic-janus-controller
