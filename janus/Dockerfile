FROM ubuntu:18.04

ARG INSTALL_DIR="/home/janus"
ARG JANUS_DIR="/opt/janus"

ENV SCRIPTS_DIR /tmp/scripts

RUN apt-get update > /dev/null && \
    apt-get install -y \
        curl \
        git \
        build-essential \
        cmake \
        gcc \
        automake \
        wget \
        libmicrohttpd-dev \
        libjansson-dev \
        libssl-dev \
        libsofia-sip-ua-dev \
        libglib2.0-dev \
        libopus-dev \
        libogg-dev \
        libini-config-dev \
        libcollection-dev \
        pkg-config \
        gengetopt \
        libcurl4-gnutls-dev \
        libtool \
        gtk-doc-tools \
        libconfig-dev

RUN mkdir -p $INSTALL_DIR && mkdir -p $JANUS_DIR/certs

ARG OPENSSL_VERSION=1.1.1f
RUN cd $INSTALL_DIR && \
  wget https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz && \
  tar xzvf openssl-$OPENSSL_VERSION.tar.gz && \
  cd $INSTALL_DIR/openssl-$OPENSSL_VERSION && \
  ./config -Wl,--enable-new-dtags,-rpath,'$(LIBRPATH)' && \
  make && \
  make install


ARG LIBSRTP_VERSION=2.2.0
RUN cd ${INSTALL_DIR} && \
  wget https://github.com/cisco/libsrtp/archive/v${LIBSRTP_VERSION}.tar.gz && \
  tar xfv v${LIBSRTP_VERSION}.tar.gz && \
  cd ${INSTALL_DIR}/libsrtp-${LIBSRTP_VERSION} && \
  ./configure --prefix=/usr --enable-openssl && \
  make shared_library && make install

# install libnice
#ARG LIBNICE_VERSION=tags/0.1.16

# install build deps
RUN apt-get update > /dev/null && \
      apt-get install -y \
      python3 python3-pip python3-setuptools python3-wheel ninja-build
RUN pip3 install meson
ARG LIBNICE_VERSION=master
RUN git clone https://gitlab.freedesktop.org/libnice/libnice.git ${INSTALL_DIR}/libnice && \
  cd ${INSTALL_DIR}/libnice && \
  git checkout $LIBNICE_VERSION && \
  meson --prefix /usr builddir && \
  ninja -C builddir && ninja -C builddir install

# install rabbitmq
RUN git clone https://github.com/alanxz/rabbitmq-c ${INSTALL_DIR}/rabbitmq-c && \
  cd ${INSTALL_DIR}/rabbitmq-c && \
  git submodule init && \
  git submodule update && \
  mkdir build && cd build && \
  cmake -DCMAKE_INSTALL_PREFIX=/usr .. && \
  make && make install


# build libwebsockets
ARG LIBWEBSOCKETS_VERSION=3.2.1
RUN git clone https://github.com/warmcat/libwebsockets.git ${INSTALL_DIR}/libwebsockets && \
  cd ${INSTALL_DIR}/libwebsockets && \
  git checkout tags/v${LIBWEBSOCKETS_VERSION} && \
  mkdir build && cd build && \
  cmake -DLWS_MAX_SMP=1 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. && \
  make && make install

# build janus gateway
#ARG JANUS_VERSION=tags/v0.10.4
ARG JANUS_VERSION=sendmmsg
RUN git clone https://github.com/meetecho/janus-gateway.git ${INSTALL_DIR}/janus-gateway && \
  cd ${INSTALL_DIR}/janus-gateway && \
  git rev-parse --verify HEAD && \
  git checkout ${JANUS_VERSION} && \
  sh autogen.sh && \
  ./configure --prefix=${JANUS_DIR} \
    --disable-docs \
    --disable-data-channels \
    --disable-rabbitmq \
    --disable-mqtt \
    --disable-plugin-lua \
    PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig && \
  make && make install

ARG DEBUG_COLORS
ARG ENABLE_EVENTS
ARG JANUS_TOKEN_SECRET
ARG RABBIT_HOST
ARG ENABLE_RABBIT_EVENTS

COPY ./start.sh /tmp/scripts/start.sh
COPY ./bootstrap.sh /tmp/scripts/bootstrap.sh

RUN mkdir /cores
RUN apt-get clean && rm -rf $INSTALL_DIR

RUN ulimit -c unlimited


CMD ["/tmp/scripts/start.sh"]
