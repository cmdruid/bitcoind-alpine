#!/bin/sh
## POSIX compliant script for generating Bitcoin RPC credentials.
## Requires the openssl library to be installed.
## Distributed under the MIT software license.

###############################################################################
# Environment
###############################################################################

RPCAUTH_USER="bitcoin"
RPCAUTH_FILE="rpcauth.conf"

###############################################################################
# Methods
###############################################################################

generate_salt() {
  ## Generates a 16 character random salt in hex format (converted to lowercase).
  echo `hexdump -n 16 -v -e '3/1 "%02X"' /dev/urandom | tr '[:upper:]' '[:lower:]'`
}

generate_password() {
  ## Generates a 32 character random password in base64 format.
  ## Includes LC_ALL=C flag for compatibility with other platforms.
  echo `
    cat /dev/urandom \
    | env LC_ALL=C tr -dc 'a-zA-Z0-9' \
    | fold -w 32 \
    | head -n 1 \
    | base64
  `
}

password_to_hmac() {
  ## Generates a SHA256 hmac, in hex format, using the provided message($1) and key($2).
  ## Input is converted into a utf-8 compatible byte-stream before the openssl digest.
  KEY=`printf %s "$2" | iconv -t utf-8`
  echo `
    printf %s "$1" \
    | iconv -t utf-8 \
    | openssl dgst -sha256 -hmac "$KEY" -hex \
    | awk -F = '/=/{print $2}'
  `
}

###############################################################################
# Script
###############################################################################

set -e

## If --help or not input is provided, print help screen.
if [ $1 = "--help" ] || [ $1 = "-h" ]; then
  printf "
    Generate login credentials for a JSON-RPC user.

    Usage: rpcauth.sh [username] [password]

    Both username and password arguments are optional. Output will generate 
    an rpcauth.conf file (at script root), plus print credentials to console.
  \n"
  exit 0
fi

## If a previous rpcauth file exists, remove it.
if [ -f $RPCAUTH_FILE ]; then
  rm $RPCAUTH_FILE
fi

## If a user is specified, update variable.
if ! [ -z $1 ]; then
  RPCAUTH_USER=$1
fi

## If a password is specified, update variable.
if ! [ -z $2 ]; then
  RPCAUTH_PASS=$2
else
  RPCAUTH_PASS=`generate_password`
fi

## Create our credentials and store them.
SALT=`generate_salt`
HMAC=`password_to_hmac $RPCAUTH_PASS $SALT`

## Add credentials to rpcauth file.
RPCAUTH_STR="${RPCAUTH_USER}:${SALT}\$${HMAC}"
echo "#rpcuser=$RPCAUTH_USER" >> $RPCAUTH_FILE
echo "#rpcpass=$RPCAUTH_PASS" >> $RPCAUTH_FILE
echo "rpcauth=$RPCAUTH_STR" >> $RPCAUTH_FILE

## Print our credentials to console as a JSON compatible object.
printf "{
\t\"username\": \"$RPCAUTH_USER\",
\t\"password\": \"$RPCAUTH_PASS\",
\t\"salt\": \"$SALT\",
\t\"hmac\": \"$HMAC\"
\t\"rpcauth\": \"$RPCAUTH_STR\"
}\n"
