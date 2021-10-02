#!/bin/bash

mkdir -p /var/www/ && cd /var/www/

set -e

LATEST_TAG=$(curl -sL api.github.com/repos/jumpinchat/jumpinchat-web/releases/latest | jq .tag_name | sed 's/v//' | sed 's/"//g')
echo $LATEST_TAG
FILE_NAME=jic-web-${LATEST_TAG}.zip
GH_URL=https://github.com/jumpinchat/jumpinchat-web/releases/download/${LATEST_TAG}/${FILE_NAME}


curl -sL ${GH_URL} -o ./${FILE_NAME}
unzip ${FILE_NAME}
