FROM node:10 as builder

ENV SERVER_PATH /var/www
ENV ACTIVE_BRANCH "master"
ENV SCRIPTS_DIR /tmp/scripts
ENV NODE_ENV "production"
ENV PORT 3000
ENV MONGODB_URI "mongodb://mongodb/tc"


RUN apt-get update > /dev/null
RUN apt-get install -y \
        curl \
        git \
        sudo \
        python \
        python-dev \
        build-essential

# install pip, in order to download aws cli
RUN curl -sL https://bootstrap.pypa.io/get-pip.py | python

# install aws cli
RUN pip install awscli

# install node dependencies
RUN mkdir -p /tmp/scripts
COPY . /tmp/scripts/

RUN chmod +x /tmp/scripts/build.sh
RUN /tmp/scripts/build.sh

RUN chmod +x /tmp/scripts/entry.sh

FROM node:10
COPY --from=builder /var/www /var/www
COPY --from=builder /tmp/scripts/entry.sh /tmp/scripts/entry.sh
ENTRYPOINT ["/tmp/scripts/entry.sh"]
