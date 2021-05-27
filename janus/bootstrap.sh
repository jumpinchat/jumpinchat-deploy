#!/usr/bin/env bash

set -e

INSTALL_DIR="/home/janus"
JANUS_DIR="/opt/janus"

if [ -z "${JANUS_TOKEN_SECRET}" ]; then
  echo "janus token secret is missing" >&2
  exit 1
fi

if [ -z "${SERVER_NAME}" ]; then
  echo "server name is missing" >&2
  exit 1
fi

# set colors from env var if it exists
# set this to 'no' for prod so logs
# don't get polluted by color codes
if [ -z "${DEBUG_COLORS}" ]; then
  DEBUG_COLORS=true
fi

if [ -z "${ENABLE_EVENTS}" ]; then
  ENABLE_EVENTS=true
fi

if [ -z "${ENABLE_RABBIT_EVENTS}" ]; then
  ENABLE_RABBIT_EVENTS=true
fi

if [ -z "${RABBIT_HOST}" ]; then
  RABBIT_HOST="rabbitmq"
fi

echo "generating the config file"

# make the janus configuration
cat << EOF > ${JANUS_DIR}/etc/janus/janus.jcfg
general: {
  configs_folder = "${JANUS_DIR}/etc/janus"
  plugins_folder = "${JANUS_DIR}/lib/janus/plugins"
  debug_level = 4
  debug_timestamps = true
  debug_colors = ${DEBUG_COLORS}
  server_name = "${SERVER_NAME}"
  session_timeout = 60
  reclaim_session_timeout = 60

  token_auth = true
  token_auth_secret = "${JANUS_TOKEN_SECRET}"

}

nat: {
  stun_server = "stun1.l.google.com"
  stun_port = 19302
  server_name = "JumpInChat"
  full_trickle = true
  ice_enforce_list = "eth0,enp0s31f6"
  nice_debug = false
}

certificates: {
  cert_pem = "${JANUS_DIR}/certs/fullchain.pem"
  cert_key = "${JANUS_DIR}/certs/privkey.pem"
}

media: {
  no_media_timer = 5
}

plugins: {
  disable = "libjanus_voicemail.so,libjanus_recordplay.so,libjanus_audiobridge.so,libjanus_videocall.so,libjanus_voicemail.so,libjanus_recordplay.so,libjanus_sip.so,libjanus_textroom.so,libjanus_echotest.so"
}

events: {
  broadcast = ${ENABLE_EVENTS}
  disable = "libjanus_mqttevh.so,libjanus_wsevh.so,libjanus_rabbitmqevh.so,libjanus_nanomsgevh.so"
  stats_period = 0
}

EOF

cat << EOF > ${JANUS_DIR}/etc/janus/janus.transport.http.jcfg
general: {
  base_path = "/janus"
  threads = "unlimited"
  http = true
  port = 8088
  https = true
  secure_port = 8889
}

admin: {
  admin_base_path = "/admin"
  admin_threads = "unlimited"
  admin_http = true
  admin_port = 7888
  admin_https = true
  admin_secure_port = 7889
}

certificates: {
  cert_pem = "${JANUS_DIR}/certs/fullchain.pem"
  cert_key = "${JANUS_DIR}/certs/privkey.pem"
}
EOF

cat << EOF > ${JANUS_DIR}/etc/janus/janus.transport.websockets.jcfg
general: {
  ws = true
  ws_port = 8188
  wss = true
  wss_port = 8989
}

certificates: {
  cert_pem = "${JANUS_DIR}/certs/fullchain.pem"
  cert_key = "${JANUS_DIR}/certs/privkey.pem"
}
EOF

cat << EOF > ${JANUS_DIR}/etc/janus/janus.eventhandler.sampleevh.jcfg
general: {
  enabled = ${ENABLE_EVENTS}
  events = "plugins"
  grouping = true
  backend = "http://haproxy/api/janus/events"
}
EOF

cat << EOF > ${JANUS_DIR}/etc/janus/janus.plugin.videoroom.jcfg
general: {
  string_ids = true
}
EOF

#cat << EOF > ${JANUS_DIR}/etc/janus/janus.eventhandler.rabbitmqevh.jcfg
#general: {
#  enabled = ${ENABLE_RABBIT_EVENTS}
#  events = "plugins"
#  grouping = false
#  json = "compact"
#  host = "${RABBIT_HOST}"
#  port = 5672
#  #exchange = "janus-exchange"
#  route_key = "janus-events"
#}
#EOF
