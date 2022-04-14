#!/bin/sh
## Entrypoint script for image.

###############################################################################
# Methods
###############################################################################

start_daemon() {
  ## Start program as a daemon service.
  pkill $1
  $1 $2 > /var/log/$1.log \
    & echo "$!" > /var/log/$1.pid
}

print_rpc_credentials() {
  printf "
  =============================================================================
    Address: $(cat /data/tor/services/rpc/hostname)
    RPC User: $(cat /data/bitcoin/rpcauth.conf | grep rpcuser | awk -F = '/=/{print $2}')
    RPC Password: $(cat /data/bitcoin/rpcauth.conf | grep rpcpass | awk '{sub(/=/," ")}1' | awk '{print $2}')
  =============================================================================
  \n"
}

###############################################################################
# Script
###############################################################################

## Create bitcoin data directory if missing.
DATA_DIR="/data/bitcoin"
if ! [ -d "$DATA_DIR" ]; then
  echo "Adding bitcoind data directories ..."
  mkdir $DATA_DIR
fi

## Download and unpack blockchain snapshot.
SNAPSHOT="$(ls /snapshot | grep snapshot)"
if [ -z "$(ls $DATA_DIR | grep blocks)" ] && [ -n "$SNAPSHOT" ]; then
  echo "Existing snapshot file detected, unpacking..."
  unzip /snapshot/*.zip -d $DATA_DIR
fi

## If rpcauth.conf is missing, generate credentials.
if ! [ -e "$DATA_DIR/rpcauth.conf" ]; then
  echo "Generating RPC credentials ..."
  ./rpcauth.sh bitcoin
  mv rpcauth.conf $DATA_DIR
fi

## Create tor data directory if missing.
TOR_DIR="/data/tor"
if ! [ -d "$TOR_DIR/services" ]; then
  echo "Adding tor data directories ..."
  mkdir -p -m 700 $TOR_DIR/services
  chown -R tor:tor $TOR_DIR
fi

## Initialize Tor.
start_daemon tor
echo "Starting Tor server under PID: $(cat /var/log/tor.pid) ..."

## Wait for Tor to load, then start bitcoin service.
tail -fn0 /var/log/tor.log | while read line; do
  echo "$line"
  echo "$line" | grep "Bootstrapped 100%"
  if [ $? = 0 ]; then
    echo "Tor circuit initialized!"
    print_rpc_credentials
    start_daemon bitcoind
    exit 0
  fi
done

## Tail log files of running services.
tail -f /var/log/tor.log /var/log/bitcoind.log