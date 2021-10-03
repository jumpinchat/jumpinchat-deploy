#!/bin/bash

mkdir -p /var/www/ && cd /var/www/

set -e

LATEST_TAG=$(curl -sL api.github.com/repos/jumpinchat/jumpinchat-homepage/releases/latest | jq .tag_name | sed 's/"//g')
FILE_NAME=jic-homepage-${LATEST_TAG}.zip
GH_URL=https://github.com/jumpinchat/jumpinchat-homepage/releases/download/${LATEST_TAG}/${FILE_NAME}

curl -sL ${GH_URL} -o ./${FILE_NAME}
unzip ${FILE_NAME}
rm ${FILE_NAME}
