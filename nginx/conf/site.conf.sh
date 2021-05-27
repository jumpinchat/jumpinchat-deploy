#!/usr/bin/env bash

EXTERNAL_IP=`curl -s icanhazip.com`

if [[ $ENV == 'local' ]]; then
LOC_STREAM=$(cat <<EOF
location /janus/stream {
  resolver 127.0.0.1 valid=30s;
  proxy_pass http://streamtest/;
  proxy_redirect default;
  proxy_http_version 1.1;
  proxy_set_header Upgrade \$http_upgrade;
  proxy_set_header Connection \$connection_upgrade;
}
EOF
)
fi

if [[ $ENV == 'local' ]]; then
JANUS_UPSTREAM=$(cat <<EOF
upstream websocket {
  server janus:8188;
}

upstream janusws {
  server janus:8989;
}

upstream janusws2 {
  server janus2:8989;
}

map \$cookie_janus_id \$janusServer {
  janus "janusws";
  janus2 "janusws2";
}
EOF
)
else
JANUS_UPSTREAM=$(cat <<EOF
upstream websocket {
  server janus:8188;
}

upstream janusws {
  server janus:8989;
}

upstream janusws2 {
  server janus2:8989;
}

upstream janusws3 {
  server janus3:8989;
}

upstream janusws4 {
  server janus4:8989;
}

upstream janusws5 {
  server janus5:8989;
}

map \$cookie_janus_id \$janusServer {
  janus "janusws";
  janus2 "janusws2";
  janus3 "janusws3";
  janus4 "janusws4";
  janus5 "janusws5";
}
EOF
)
fi

cat << EOF > /etc/nginx/conf.d/site.conf
map \$http_upgrade \$connection_upgrade {
  default upgrade;
  '' close;
}

${JANUS_UPSTREAM}

upstream websrv {
  ip_hash;
  server web:80 max_fails=3 fail_timeout=30s;
  server web2:80 max_fails=3 fail_timeout=30s;
}

upstream homesrv {
  server home:3000 max_fails=3 fail_timeout=30s;
  server home2:3000 max_fails=3 fail_timeout=30s;
}

geo \$limit {
  default 1;
  10.0.0.0/8 0;
  ${EXTERNAL_IP} 0;
}

map \$limit \$limit_key {
  0 "";
  1 \$binary_remote_addr;
}

# request limiting
limit_req_zone \$limit_key zone=sitelimit:10m rate=2r/s;

# caching
proxy_cache_path  /var/cache/nginx levels=1:2 keys_zone=one:8m max_size=3000m inactive=600m;
proxy_temp_path /var/tmp;

sendfile_max_chunk 512k;

# gzip
gzip on;
gzip_comp_level 6;
gzip_vary on;
gzip_min_length  1000;
gzip_proxied any;
gzip_types text/plain text/html text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;
gzip_buffers 16 8k;

server {
  listen 80;
  listen 443 ssl;
  server_name _;
  include /etc/nginx/root-ssl.conf;
  limit_req zone=sitelimit burst=100 nodelay;
  return 444;
}

server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;

  server_name "~^172\.\d{1,3}\.\d{1,3}\.\d{1,3}\$" "~^10\.136\.\d{1,3}\.\d{1,3}\$" jumpin.chat local.jumpin.chat jumpinchat.com;
  client_max_body_size 10M;

  gzip on;
  gzip_comp_level 6;
  gzip_vary on;
  gzip_min_length  1000;
  gzip_proxied any;
  gzip_types text/plain application/javascript application/x-javascript text/javascript text/xml text/css;
  gzip_buffers 16 8k;
  limit_req zone=sitelimit burst=100 nodelay;

  include /etc/nginx/root-ssl.conf;

  location / {
    try_files \$uri \$uri/ @homepage;
    proxy_cache one;
    proxy_cache_bypass \$http_cache_control;
    add_header X-Proxy-Cache \$upstream_cache_status;
    aio threads;
  }

  location /api {
    proxy_pass http://haproxy:80;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header Host \$host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Host \$host;
  }

  location @homepage {
    proxy_pass http://homesrv;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header Host \$host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Host \$host;
    proxy_intercept_errors on;
    recursive_error_pages on;
    error_page 404 = @web;
    aio threads;
  }

  location @web {
    proxy_pass http://websrv;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header Host \$host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Host \$host;
    aio threads;

    # Websocket support
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
  }

  location /janus/ws {
    proxy_pass https://\$janusServer/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$connection_upgrade;
    add_header X-JANUS-SERVER \$janusServer;
  }

  location /janus/http {
    limit_req zone=sitelimit burst=300 nodelay;
    proxy_pass http://janus:8088/janus;
    proxy_redirect default;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$connection_upgrade;
  }

  ${LOC_STREAM}

  location = /robots.txt  {
    root /var/www/site/;
  }
}

server {
  listen 80;
  listen 443 ssl;

  server_name www.jumpinchat.com www.jumpin.chat;
  server_tokens off;
  limit_req zone=sitelimit burst=10 nodelay;
  return 301 https://jumpin.chat\$request_uri;
}

server {
  listen 80;
  server_name jumpin.chat www.jumpin.chat local.jumpin.chat jumpinchat.com www.jumpinchat.com;
  server_tokens off;
  limit_req zone=sitelimit burst=10 nodelay;
  return 301 https://\$host\$request_uri;
}
EOF
