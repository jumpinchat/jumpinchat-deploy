FROM nginx:stable

RUN apt-get update > /dev/null && \
  apt-get install -y -qq \
    curl \
    sudo \
    git \
    build-essential \
    python

RUN curl https://bootstrap.pypa.io/get-pip.py | python


# Set up SSL
COPY . /tmp/scripts/

RUN mkdir -p /etc/nginx/ssl
RUN mkdir -p /var/www/site
RUN touch /var/log/auth.log
RUN mkdir -p /var/log/nginx && \
      touch /var/log/nginx/access.log && \
      touch /var/log/nginx/error.log

ARG ENV
RUN chmod +x /tmp/scripts/download-certs.sh
RUN /tmp/scripts/download-certs.sh

COPY ./site /var/www/site/

RUN mkdir -p /tmp/scripts

RUN rm /etc/nginx/conf.d/default.conf

#COPY conf/site.conf /etc/nginx/conf.d/
COPY conf/site.conf.sh /tmp/scripts/
COPY conf/nginx.conf /etc/nginx/
COPY conf/ssl.conf /etc/nginx/
COPY conf/root-ssl.conf /etc/nginx/
COPY conf/log-ssl.conf /etc/nginx/
COPY conf/root-certs.conf /etc/nginx/
COPY conf/log-certs.conf /etc/nginx/

RUN /tmp/scripts/site.conf.sh

RUN ulimit -c unlimited
