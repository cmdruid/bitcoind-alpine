FROM alpine:latest AS builder

VOLUME /root/bin

ARG BUILD_TARGET="x86_64-pc-linux-gnu"
ARG BUILD_BRANCH="master"

## Install dependencies
RUN apk update && apk add --no-cache \
  autoconf automake bash bison boost-dev build-base cmake curl git \
  libevent-dev libressl libtool linux-headers make pkgconf python3 sqlite xz

## Download source from remote repository.
RUN cd /root \
  && git clone "https://github.com/bitcoin/bitcoin.git" --branch $BUILD_BRANCH --single-branch \
  && mkdir -p /root/bitcoin/bitcoin-core

## Configure, compile and build binaries from source.
WORKDIR /root/bitcoin

RUN make -C depends NO_QT=1 NO_BDB=1 ALLOW_HOST_PACKAGES=1
RUN ./autogen.sh
RUN CONFIG_SITE=$PWD/depends/x86_64-pc-linux-musl/share/config.site \
    ./configure --prefix=/root/bitcoin/bitcoin-core --disable-tests --disable-bench --with-utils
RUN make HOST=$BUILD_TARGET && make install

## Check that binary is installed.
RUN ls bitcoin-core/bin | grep bitcoind

## Configure entrypoint.
ENTRYPOINT [ "tar" ]
CMD [ "-czvf /root/bin/bitcoin-alpine-master.tar.gz -C /root/bitcoin bitcoin-core" ]