#!/bin/sh

nginx
NODE_ENV=production node /var/www/jic-web/srv/index.js
