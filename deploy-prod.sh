#!/bin/sh

set -e

TIME_TO_RESTART=900 # 15 minutes

echo 'fetching images'
./pull-docker-images.sh

echo 'notifying clients'
curl -X POST https://jumpin.chat/api/admin/notify/restart/${TIME_TO_RESTART}
echo 'notified clients'
echo 'sleeping for 15 minutes'
sleep ${TIME_TO_RESTART}
docker-compose -f server-compose.yml up --no-deps -d
echo $(docker-compose ps)

