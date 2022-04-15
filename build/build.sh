#!/bin/sh
## Build script template. See accompanying Dockerfile for more build options.

###############################################################################
# Environment
###############################################################################

IMG_NAME="bitcoind-alpine-builder"
BUILD_DIR="$(dirname "$(realpath "$0")")"/

###############################################################################
# Script
###############################################################################

set -e

echo "Current build directory: $BUILD_DIR"

## If out/ path does not exist, create it.
if [ ! -d "$BUILD_DIR/out" ]; then
  mkdir "$BUILD_DIR/out"
fi

## If previous docker image exists, remove it.
if [ -n "$(docker image ls | grep $IMG_NAME)" ]; then
  docker image rm $IMG_NAME
fi

## Begin building image.
echo "Building binary from dockerfile... "
DOCKER_BUILDKIT=1 docker build $1 \
  --tag $IMG_NAME \
  --output type=local,dest=$BUILD_DIR/out \
$BUILD_DIR
