FROM alpine:latest

VOLUME /data
VOLUME /snapshot

## Install dependencies.
RUN apk update && apk add --no-cache boost-dev curl gnupg openssl procps tor unzip

## Copy, unpack, and install bitcoin binaries.
COPY build/out/bitcoin* /tmp/
WORKDIR /tmp

RUN tar --strip-components=1 -C /usr -xzf  *.tar.gz
RUN echo "bitcoind installed in $(which bitcoind)"
RUN rm -rf /tmp/* /var/tmp/*

## Uncomment this if you also want to wipe all repository lists.
#RUN rm -rf /var/lib/apt/lists/*

## Check bitcoind is installed.
RUN bitcoind -version | grep "Bitcoin Core version"

## Copy configuration files.
COPY config/torrc /etc/tor/
COPY config/bitcoin.conf /root/.bitcoin/

## Configure user account for Tor.
RUN addgroup tor && adduser tor tor

## Setup entrypoint for image.
COPY scripts/* /root/
RUN chmod +x /root/*

WORKDIR /root
ENTRYPOINT ["./entrypoint.sh"]
