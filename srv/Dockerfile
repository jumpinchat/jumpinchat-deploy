FROM nginx:stable

MAINTAINER Zaccary Price "wildtangomedia@gmail.com"

ENV SERVER_PATH /var/www
ENV ACTIVE_BRANCH "master"
ENV SCRIPTS_DIR /tmp/scripts
ENV NODE_ENV "production"
ENV PORT 8080
ENV REDIS_URI "redis://redis:6379"
ENV MONGODB_URI "mongodb://mongodb/tc"
ENV JANUS_HTTP_URI_INTERNAL "http://janus:8088/janus"
ENV JANUS_WS_URI_INTERNAL "ws://janus:8188"
ENV JANUS_BITRATE 128000
ENV JANUS_ROOM_SIZE 12
ENV TURN_URIS "turn.jumpin.chat"


RUN apt-get update > /dev/null
RUN apt-get install -yqq --no-install-recommends \
        curl \
        git \
        sudo \
        python3-pip \
        python3-wheel \
        build-essential

# install aws cli
RUN pip3 install setuptools --upgrade
RUN pip3 install wheel
RUN pip3 install awscli --upgrade

# install node dependencies
RUN mkdir -p /tmp/scripts
COPY . /tmp/scripts/

RUN chmod +x /tmp/scripts/nodejs.sh
RUN /tmp/scripts/nodejs.sh

RUN chmod +x /tmp/scripts/build.sh
RUN /tmp/scripts/build.sh

RUN chmod +x /tmp/scripts/entry.sh

RUN rm /etc/nginx/conf.d/default.conf
COPY conf/site.conf /etc/nginx/conf.d/

ENTRYPOINT ["/tmp/scripts/entry.sh"]
