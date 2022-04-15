FROM alpine:latest AS build-stage

ENV BUILD_TARGET="x86_64-pc-linux-gnu"
ENV BUILD_BRANCH="22.x"
ENV REPO_URL="https://github.com/bitcoin/bitcoin.git"
ENV REPO_DIR="bitcoin"

ENV PATH="/root/.local/bin:$PATH"
ENV TAR_NAME="$REPO_DIR-$BUILD_TARGET-$BUILD_BRANCH"

## Prepare directories.
RUN mkdir -p /root/bin && mkdir -p /root/out

## Install dependencies
RUN apk update && apk add --no-cache \
  autoconf automake bash bison boost-dev build-base cmake curl git \
  libevent-dev libressl libtool linux-headers make pkgconf python3 sqlite xz

## Download source from remote repository.
RUN cd /root \
  && git clone $REPO_URL --branch $BUILD_BRANCH --single-branch

## Configure, compile and build binaries from source.
WORKDIR /root/$REPO_DIR

RUN make -C depends NO_QT=1 NO_BDB=1 ALLOW_HOST_PACKAGES=1
RUN ./autogen.sh
RUN CONFIG_SITE=$PWD/depends/x86_64-pc-linux-musl/share/config.site \
    ./configure --prefix=/root/bin/$TAR_NAME --disable-tests --disable-bench --with-utils
RUN make HOST=$BUILD_TARGET && make install

## Prepare binary as tarball.
RUN ls /root/bin | grep $TAR_NAME
RUN tar -czvf /root/out/$TAR_NAME.tar.gz -C /root/bin $TAR_NAME

## Extract binary archive.
FROM scratch AS export-stage
COPY --from=build-stage /root/out /